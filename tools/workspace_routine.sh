#!/bin/sh
set -eu

root=${1:-.}
root=$(CDPATH= cd -- "$root" && pwd)
if [ -x "$root/dephy_todo/tools/dephy_todo.py" ]; then
    todo_tool="$root/dephy_todo/tools/dephy_todo.py"
elif [ -x "$root/tools/dephy_todo.py" ]; then
    todo_tool="$root/tools/dephy_todo.py"
else
    echo "missing dephy_todo tool under $root" >&2
    exit 1
fi


echo "## repos"
find "$root" -maxdepth 2 -name repo.json -not -path '*/deps/*' -print |
    while IFS= read -r repo_json; do
        repo=$(dirname "$repo_json")
        name=$(basename "$repo")
        status=$(git -C "$repo" status --short 2>/dev/null | wc -l | tr -d ' ')
        head=$(git -C "$repo" log -1 --oneline 2>/dev/null || true)
        printf '%-28s dirty=%s %s\n' "$name" "$status" "$head"
    done

echo
echo "## open todo"
python3 "$todo_tool" global-list "$root" --open-only

echo
echo "## suggested tests"
find "$root" -maxdepth 2 -name repo.json -not -path '*/deps/*' -print |
    while IFS= read -r repo_json; do
        repo=$(dirname "$repo_json")
        name=$(basename "$repo")
        if [ -f "$repo/Makefile.linux" ]; then
            printf '%-28s make -f Makefile.linux -C %s test\n' "$name" "$repo"
        elif [ -f "$repo/Makefile" ]; then
            printf '%-28s make -C %s test\n' "$name" "$repo"
        elif [ -f "$repo/tests/linux/Makefile" ]; then
            printf '%-28s make -C %s/tests/linux test\n' "$name" "$repo"
        fi
    done

echo
echo "## key files"
find "$root" -maxdepth 3 \
    \( -path '*/.git' -o -path '*/build' -o -path '*/build_out' -o -path '*/deps' -o -path '*/out' \) -prune \
    -o \( -name repo.json -o -name 'todo.yaml' -o -name 'module_structure.md' -o -name AGENTS.md -o -name Makefile.linux \) -print |
    sort
