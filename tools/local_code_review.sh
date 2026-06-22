#!/bin/sh
set -eu

usage()
{
    cat <<'EOF'
usage: tools/local_code_review.sh [--dry-run] [--provider ollama|openai] [--base-url URL] [--model MODEL] [REPO]

Runs a local-model preliminary code review for a git repository.

Defaults:
  provider:  ollama
  base URL:  http://127.0.0.1:11434
  model:     DEPHY_LOCAL_REVIEW_MODEL, OLLAMA_MODEL, or auto-detected Ollama model

OpenAI-compatible mode works with vLLM, llama.cpp server, or similar endpoints:
  DEPHY_LOCAL_REVIEW_PROVIDER=openai
  DEPHY_LOCAL_REVIEW_BASE_URL=http://127.0.0.1:8000/v1
  DEPHY_LOCAL_REVIEW_MODEL=Qwen2.5-Coder-7B-Instruct

Environment:
  DEPHY_LOCAL_REVIEW_PROVIDER
  DEPHY_LOCAL_REVIEW_BASE_URL
  DEPHY_LOCAL_REVIEW_MODEL
  DEPHY_LOCAL_REVIEW_MAX_CHARS
  DEPHY_LOCAL_REVIEW_OUT
  DEPHY_LOCAL_REVIEW_QUALITY_GATE=0 disables the Markdown findings gate
EOF
}

dry_run=0
provider=${DEPHY_LOCAL_REVIEW_PROVIDER:-ollama}
base_url=${DEPHY_LOCAL_REVIEW_BASE_URL:-}
model=${DEPHY_LOCAL_REVIEW_MODEL:-${OLLAMA_MODEL:-}}
repo=.

while [ "$#" -gt 0 ]; do
    case "$1" in
        --dry-run)
            dry_run=1 ;;
        --provider)
            shift
            provider=${1:?missing provider} ;;
        --base-url)
            shift
            base_url=${1:?missing base URL} ;;
        --model)
            shift
            model=${1:?missing model} ;;
        -h|--help)
            usage
            exit 0 ;;
        -*)
            echo "error: unknown option $1" >&2
            usage >&2
            exit 2 ;;
        *)
            repo=$1 ;;
    esac
    shift
done

repo=$(CDPATH= cd -- "$repo" && pwd)

if [ -z "$base_url" ]; then
    case "$provider" in
        ollama) base_url=http://127.0.0.1:11434 ;;
        openai|vllm) base_url=http://127.0.0.1:8000/v1 ;;
        *)
            echo "error: unknown provider $provider" >&2
            exit 2 ;;
    esac
fi

if [ -z "$model" ] && [ "$provider" = "ollama" ]; then
    model=$(python3 - "$base_url" <<'PY'
import json
import os
import sys
import urllib.request

base_url = sys.argv[1].rstrip("/")
preferred = ("qwen", "codellama", "llama3.2", "llama", "mistral", "deepseek-coder")
try:
    with urllib.request.urlopen(base_url + "/api/tags", timeout=3) as resp:
        models = json.loads(resp.read().decode("utf-8")).get("models", [])
except Exception:
    models = []
names = [m.get("name", "") for m in models]
for needle in preferred:
    for name in names:
        if needle in name.lower():
            print(name)
            raise SystemExit(0)
if names:
    print(names[0])
PY
)
fi

if [ -z "$model" ]; then
    case "$provider" in
        ollama) model=codellama ;;
        *) model=Qwen2.5-Coder-7B-Instruct ;;
    esac
fi

max_chars=${DEPHY_LOCAL_REVIEW_MAX_CHARS:-60000}
out=${DEPHY_LOCAL_REVIEW_OUT:-}
if [ -z "$out" ]; then
    out="$repo/build_out/local_code_review.md"
fi
mkdir -p "$(dirname "$out")"

tmp=${TMPDIR:-/tmp}/dephy-local-review.$$
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT

{
    echo "# repository"
    basename "$repo"
    echo
    echo "# status"
    git -C "$repo" status --short || true
    echo
    echo "# recent commits"
    git -C "$repo" log --oneline -5 || true
    echo
    echo "# changed files"
    git -C "$repo" diff --name-status HEAD || true
    echo
    echo "# diff"
    if ! git -C "$repo" diff --no-ext-diff --unified=80 HEAD; then
        git -C "$repo" diff --no-ext-diff --unified=80 || true
    fi
} > "$tmp/context.txt"

python3 - "$tmp/context.txt" "$tmp/prompt.txt" "$max_chars" <<'PY'
import sys
from pathlib import Path

context = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
max_chars = int(sys.argv[3])
if len(context) > max_chars:
    context = context[:max_chars] + "\n\n[context truncated by DEPHY_LOCAL_REVIEW_MAX_CHARS]\n"

prompt = f"""You are a strict senior code reviewer.

Review the repository changes below. Focus on bugs, regressions, security issues,
resource leaks, missing tests, race conditions, portability issues, and unclear
ownership boundaries. Do not praise the code. If there are no findings, say so
and list residual risks. Use concise Markdown with:

## Findings
- severity: file:line - issue and concrete fix

## Test Gaps
- missing or insufficient validation

## Notes
- assumptions or follow-up checks

Repository context:

{context}
"""
Path(sys.argv[2]).write_text(prompt, encoding="utf-8")
PY

if [ "$dry_run" = "1" ]; then
    {
        echo "# local code review dry run"
        printf 'repo=%s\n' "$repo"
        printf 'provider=%s\n' "$provider"
        printf 'base_url=%s\n' "$base_url"
        printf 'model=%s\n' "$model"
        printf 'prompt_chars=%s\n' "$(wc -c < "$tmp/prompt.txt" | tr -d ' ')"
    } | tee "$out"
    exit 0
fi

python3 - "$provider" "$base_url" "$model" "$tmp/prompt.txt" "$out" <<'PY'
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

provider, base_url, model, prompt_path, out_path = sys.argv[1:6]
prompt = Path(prompt_path).read_text(encoding="utf-8")

def post_json(url: str, payload: dict) -> dict:
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=600) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.URLError as exc:
        raise SystemExit(f"local review request failed: {exc}") from exc

if provider == "ollama":
    result = post_json(
        base_url.rstrip("/") + "/api/generate",
        {
            "model": model,
            "prompt": prompt,
            "stream": False,
            "options": {"temperature": 0.1},
        },
    )
    text = result.get("response", "")
elif provider in {"openai", "vllm"}:
    result = post_json(
        base_url.rstrip("/") + "/chat/completions",
        {
            "model": model,
            "temperature": 0.1,
            "messages": [
                {"role": "system", "content": "You are a strict senior code reviewer."},
                {"role": "user", "content": prompt},
            ],
        },
    )
    text = result["choices"][0]["message"]["content"]
else:
    raise SystemExit(f"unknown provider: {provider}")

if not text.strip():
    raise SystemExit("local review returned empty response")

Path(out_path).write_text(text, encoding="utf-8")
if os.environ.get("DEPHY_LOCAL_REVIEW_QUALITY_GATE", "1") != "0":
    required = ("## Findings", "## Test Gaps")
    missing = [marker for marker in required if marker not in text]
    if missing:
        raise SystemExit(
            "local review failed quality gate; missing "
            + ", ".join(missing)
            + ". Try a stronger instruct model or set DEPHY_LOCAL_REVIEW_QUALITY_GATE=0."
        )
print(f"local_review_out={out_path}")
PY
