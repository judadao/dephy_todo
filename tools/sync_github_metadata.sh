#!/bin/sh
set -eu

root=${1:-.}
token=${GITHUB_TOKEN:-${GH_TOKEN:-}}

if [ -z "$token" ]; then
    echo "error: set GITHUB_TOKEN or GH_TOKEN" >&2
    exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "error: jq is required" >&2
    exit 2
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "error: curl is required" >&2
    exit 2
fi

api=${GITHUB_API_URL:-https://api.github.com}

remote_repo()
{
    repo_dir=$1
    url=$(git -C "$repo_dir" remote get-url origin 2>/dev/null || true)
    case "$url" in
        git@github.com:*.git)
            printf '%s\n' "$url" | sed 's#git@github.com:##; s#\\.git$##'
            ;;
        https://github.com/*.git)
            printf '%s\n' "$url" | sed 's#https://github.com/##; s#\\.git$##'
            ;;
        https://github.com/*)
            printf '%s\n' "$url" | sed 's#https://github.com/##'
            ;;
        *)
            return 1
            ;;
    esac
}

find "$root" -name repo.json \
    -not -path '*/deps/*' \
    -not -path '*/build/*' \
    -not -path '*/build_out/*' \
    -not -path '*/out/*' |
while IFS= read -r meta; do
    repo_dir=$(dirname "$meta")
    full=$(remote_repo "$repo_dir" || true)
    if [ -z "$full" ]; then
        echo "$repo_dir: skip, no GitHub origin" >&2
        continue
    fi

    description=$(jq -r '.description // empty' "$meta")
    topics=$(jq -c '{names: (.topics // [])}' "$meta")

    if [ -n "$description" ]; then
        jq -n --arg description "$description" '{description: $description}' |
            curl -fsS -X PATCH "$api/repos/$full" \
                -H "Authorization: Bearer $token" \
                -H "Accept: application/vnd.github+json" \
                -H "X-GitHub-Api-Version: 2022-11-28" \
                -d @- >/dev/null
    fi

    printf '%s\n' "$topics" |
        curl -fsS -X PUT "$api/repos/$full/topics" \
            -H "Authorization: Bearer $token" \
            -H "Accept: application/vnd.github+json" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            -d @- >/dev/null

    echo "$full: metadata synced"
done
