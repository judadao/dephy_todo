#!/bin/sh
set -eu

root=${1:-.}
root=$(CDPATH= cd -- "$root" && pwd)
out_dir=${OUT_DIR:-"$root/.dephy_routine/cppcheck"}
case "$out_dir" in
    /*) ;;
    *) out_dir="$PWD/$out_dir" ;;
esac
fail_on_findings=${DEPHY_CPPCHECK_FAIL_ON_FINDINGS:-0}
mkdir -p "$out_dir"

if ! command -v cppcheck >/dev/null 2>&1; then
    echo "cppcheck=missing"
    exit 0
fi

echo "cppcheck=$(command -v cppcheck)"
printf 'root=%s\n' "$root"
printf 'out_dir=%s\n' "$out_dir"

find "$root" -maxdepth 2 -name repo.json -not -path '*/deps/*' -print |
    while IFS= read -r repo_json; do
        repo=$(dirname "$repo_json")
        name=$(basename "$repo")
        paths=""
        for p in include src tests platform examples app/src tests/linux tools; do
            if [ -e "$repo/$p" ]; then
                paths="$paths $p"
            fi
        done
        if [ -z "$paths" ]; then
            continue
        fi
        if ! find "$repo" -maxdepth 3 \( -name '*.c' -o -name '*.h' \) \
            -not -path '*/deps/*' -not -path '*/build/*' \
            -not -path '*/build_out/*' -not -path '*/out/*' |
            grep -q .; then
            continue
        fi

        log="$out_dir/$name.log"
        # shellcheck disable=SC2086
        (cd "$repo" && cppcheck --enable=warning,style,performance,portability \
            --inline-suppr --quiet $paths >"$log" 2>&1) || true
        count=$(grep -Ec '^[^:]+:[0-9]+:[0-9]+: (warning|style|performance|portability|error):' "$log" || true)
        printf '%s\tfindings=%s\t%s\n' "$name" "$count" "$log"
    done > "$out_dir/results.tsv"

cat "$out_dir/results.tsv"

total=$(awk -F '\t' '
    {
        split($2, a, "=");
        total += a[2];
    }
    END { print total + 0 }
' "$out_dir/results.tsv")
printf 'total_findings=%s\n' "$total"

if [ "$fail_on_findings" = "1" ] && [ "$total" -ne 0 ]; then
    exit 1
fi
