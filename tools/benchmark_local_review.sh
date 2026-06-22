#!/bin/sh
set -eu

repo=${1:-.}
repo=$(CDPATH= cd -- "$repo" && pwd)
script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
iterations=${DEPHY_LOCAL_REVIEW_BENCH_ITERATIONS:-3}
run_model=${DEPHY_LOCAL_REVIEW_BENCH_MODEL:-0}
out=${DEPHY_LOCAL_REVIEW_BENCH_OUT:-"$repo/build_out/local_review_benchmark.txt"}
mkdir -p "$(dirname "$out")"

now_ms()
{
    python3 - <<'PY'
import time
print(int(time.time() * 1000))
PY
}

gpu="none"
if command -v nvidia-smi >/dev/null 2>&1; then
    gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n 1 || true)
    [ -z "$gpu" ] && gpu="nvidia-unavailable"
elif command -v rocminfo >/dev/null 2>&1; then
    gpu="rocm-detected"
fi

model=${DEPHY_LOCAL_REVIEW_MODEL:-${OLLAMA_MODEL:-auto}}
provider=${DEPHY_LOCAL_REVIEW_PROVIDER:-ollama}
first_dry="$repo/build_out/local_review_dry_1.txt"

{
    echo "# local review benchmark"
    printf 'repo=%s\n' "$repo"
    printf 'provider=%s\n' "$provider"
    printf 'model=%s\n' "$model"
    printf 'gpu=%s\n' "$gpu"
    printf 'iterations=%s\n' "$iterations"
    echo
    echo "## dry_run_context"
} > "$out"

i=1
total=0
while [ "$i" -le "$iterations" ]; do
    start=$(now_ms)
    DEPHY_LOCAL_REVIEW_OUT="$repo/build_out/local_review_dry_$i.txt" \
        "$script_dir/local_code_review.sh" --dry-run "$repo" >/dev/null
    end=$(now_ms)
    elapsed=$((end - start))
    total=$((total + elapsed))
    printf 'run_%s_ms=%s\n' "$i" "$elapsed" >> "$out"
    i=$((i + 1))
done
avg=$((total / iterations))
resolved_model=$model
if [ -f "$first_dry" ]; then
    resolved_model=$(sed -n 's/^model=//p' "$first_dry" | head -n 1)
fi
printf 'resolved_model=%s\n' "$resolved_model" >> "$out"
printf 'avg_ms=%s\n' "$avg" >> "$out"

if [ "$run_model" = "1" ]; then
    echo >> "$out"
    echo "## model_review" >> "$out"
    start=$(now_ms)
    DEPHY_LOCAL_REVIEW_OUT="$repo/build_out/local_code_review.md" \
        "$script_dir/local_code_review.sh" "$repo" >/dev/null
    end=$(now_ms)
    elapsed=$((end - start))
    printf 'elapsed_ms=%s\n' "$elapsed" >> "$out"
    printf 'output=%s\n' "$repo/build_out/local_code_review.md" >> "$out"
else
    echo >> "$out"
    echo "## model_review" >> "$out"
    echo "skipped=set DEPHY_LOCAL_REVIEW_BENCH_MODEL=1 to benchmark Ollama/vLLM generation" >> "$out"
fi

cat "$out"
