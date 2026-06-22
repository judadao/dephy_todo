#!/bin/sh
set -eu

root=${1:-.}
root=$(CDPATH= cd -- "$root" && pwd)
jobs=${JOBS:-}

if [ -z "$jobs" ]; then
    if command -v nproc >/dev/null 2>&1; then
        jobs=$(nproc)
    else
        jobs=4
    fi
fi

gpu="none"
if command -v nvidia-smi >/dev/null 2>&1; then
    gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n 1 || true)
    [ -z "$gpu" ] && gpu="nvidia-unavailable"
elif command -v rocminfo >/dev/null 2>&1; then
    gpu="rocm-detected"
fi

echo "## acceleration"
printf 'root=%s\n' "$root"
printf 'jobs=%s\n' "$jobs"
printf 'gpu=%s\n' "$gpu"

echo
echo "## code index"
if command -v rg >/dev/null 2>&1; then
    rg --files "$root" \
        -g '!**/.git/**' \
        -g '!**/build/**' \
        -g '!**/build_out/**' \
        -g '!**/deps/**' \
        -g '!**/out/**' \
        -g '!**/zephyrproject/**' |
        awk '
            /[.][ch]$/ { c++ }
            /[.]sh$/ { sh++ }
            /[.]py$/ { py++ }
            /[.]md$/ { md++ }
            /todo[.]yaml$/ { todo++ }
            END {
                printf "c=%d\nsh=%d\npy=%d\nmd=%d\ntodo_yaml=%d\n", c, sh, py, md, todo
            }'
else
    echo "rg=missing"
fi

echo
echo "## concurrent smoke"
tmp=${TMPDIR:-/tmp}/dephy-local-accel.$$
mkdir -p "$tmp"
trap 'rm -rf "$tmp"' EXIT

find "$root" -maxdepth 2 -name repo.json -not -path '*/deps/*' -print |
    while IFS= read -r repo_json; do
        repo=$(dirname "$repo_json")
        name=$(basename "$repo")
        if [ -f "$repo/Makefile.linux" ]; then
            printf '%s\tmake -f Makefile.linux -C %s test\n' "$name" "$repo"
        elif [ -f "$repo/Makefile" ]; then
            printf '%s\tmake -C %s test\n' "$name" "$repo"
        elif [ -f "$repo/tests/linux/Makefile" ]; then
            printf '%s\tmake -C %s/tests/linux test\n' "$name" "$repo"
        fi
    done > "$tmp/tests.tsv"

cut -f1 "$tmp/tests.tsv" | tr '\n' ' '
printf '\n'
printf 'test_commands=%s\n' "$(wc -l < "$tmp/tests.tsv" | tr -d ' ')"

echo
echo "## note"
echo "GPU detection is reported for local schedulers/indexers; current shell checks use CPU parallelism fallback."
