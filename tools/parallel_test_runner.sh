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

out_dir=${OUT_DIR:-"$root/.dephy_routine"}
mkdir -p "$out_dir"
tests_file="$out_dir/quick-tests.tsv"
results_file="$out_dir/quick-tests.results"
: > "$tests_file"
: > "$results_file"

emit_test() {
    name=$1
    cmd=$2
    printf '%s\t%s\n' "$name" "$cmd" >> "$tests_file"
}

find "$root" -maxdepth 2 -name repo.json -not -path '*/deps/*' -print |
    while IFS= read -r repo_json; do
        repo=$(dirname "$repo_json")
        name=$(basename "$repo")
        if [ "${DEPHY_PARALLEL_SKIP_SELF:-0}" = "1" ] && [ "$name" = "dephy_todo" ]; then
            continue
        fi
        case "$name" in
            mqtt_field_bridge_app)
                emit_test "$name" "make -C '$repo/tests/linux' unit-tests provisioning-render-size testkit-wrapper" ;;
            mqtt_min_broker)
                emit_test "$name" "make -f Makefile.linux -C '$repo' unit-tests packet-buffer-audit testkit-wrapper" ;;
            dephy)
                emit_test "$name" "sh '$repo/boards/esp32/scripts/test_profile.sh' && sh '$repo/boards/esp32/scripts/sync_zephyr_modules.sh' --check" ;;
            *)
                if [ -f "$repo/Makefile.linux" ]; then
                    emit_test "$name" "make -f Makefile.linux -C '$repo' test"
                elif [ -f "$repo/Makefile" ]; then
                    emit_test "$name" "make -C '$repo' test"
                elif [ -f "$repo/tests/linux/Makefile" ]; then
                    emit_test "$name" "make -C '$repo/tests/linux' test"
                fi ;;
        esac
    done

start=$(date +%s)
printf 'parallel_jobs=%s\n' "$jobs"
printf 'test_count=%s\n' "$(wc -l < "$tests_file" | tr -d ' ')"

if xargs -P "$jobs" -I '{}' sh -c '
    line=$1
    out_dir=$2
    name=${line%%	*}
    cmd=${line#*	}
    log="$out_dir/$name.log"
    started=$(date +%s)
    if sh -c "$cmd" > "$log" 2>&1; then
        status=pass
        code=0
    else
        status=fail
        code=$?
    fi
    ended=$(date +%s)
    printf "%s\t%s\t%d\t%d\t%s\n" "$name" "$status" "$code" "$((ended - started))" "$log"
    exit "$code"
' sh '{}' "$out_dir" < "$tests_file" > "$results_file"; then
    overall=0
else
    overall=1
fi

end=$(date +%s)
cat "$results_file"
printf 'total_seconds=%d\n' "$((end - start))"
exit "$overall"
