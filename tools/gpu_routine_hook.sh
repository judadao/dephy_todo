#!/bin/sh
set -eu

root=${1:-.}
root=$(CDPATH= cd -- "$root" && pwd)

gpu="none"
if command -v nvidia-smi >/dev/null 2>&1; then
    gpu=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n 1 || true)
    [ -z "$gpu" ] && gpu="nvidia-unavailable"
elif command -v rocminfo >/dev/null 2>&1; then
    gpu="rocm-detected"
fi

printf 'gpu=%s\n' "$gpu"

if [ -z "${DEPHY_GPU_ROUTINE_CMD:-}" ]; then
    if [ "${DEPHY_LOCAL_REVIEW:-0}" = "1" ]; then
        if [ -x "$root/dephy_todo/tools/local_code_review.sh" ]; then
            cmd="$root/dephy_todo/tools/local_code_review.sh $root"
        elif [ -x "$root/tools/local_code_review.sh" ]; then
            cmd="$root/tools/local_code_review.sh $root"
        else
            echo "local_code_review.sh not found under $root" >&2
            exit 2
        fi
        echo "running_local_review=$cmd"
        sh -c "$cmd"
        exit 0
    fi
    echo "DEPHY_GPU_ROUTINE_CMD not set; CPU fallback only."
    echo "Example: DEPHY_GPU_ROUTINE_CMD='your-indexer --root {root}' $0 $root"
    echo "Example: DEPHY_LOCAL_REVIEW=1 DEPHY_LOCAL_REVIEW_MODEL=codellama $0 $root"
    exit 0
fi

case "$gpu" in
    none|nvidia-unavailable)
        echo "GPU unavailable; skipping GPU routine command."
        exit 0 ;;
esac

cmd=$(printf '%s' "$DEPHY_GPU_ROUTINE_CMD" | sed "s#{root}#$root#g")
echo "running_gpu_cmd=$cmd"
sh -c "$cmd"
