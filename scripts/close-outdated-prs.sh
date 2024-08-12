#!/usr/bin/env bash
set -eu

# CURDIR=$(cd "$(dirname "$0")" && pwd)
# readonly CURDIR

info(){
    printf "[info] %s\n" "$*"
}

usage(){
    cat <<EOF
Usage: $0 -p PREFIX VERSION
Close outdated pull requests

A pull request is removed if the head branch is prefixed with PREFIX
and is older than VERSION.

Options:
    -h                  help
EOF
}

read_args(){
    set +u
    local opt
    while getopts hp: opt; do
        case "$opt" in
            h) usage; exit 0 ;;
            p) readonly PREFIX=$OPTARG ;;
            *) usage; exit 1 ;;
        esac
    done

    shift $((OPTIND - 1))

    [ -n "$PREFIX" ] || { usage; exit 1; }

    [ $# -eq 1 ] || { usage; exit 1; }
    readonly VERSION=$1
    set -u
}

retrieve_prs(){
    local FILTER=".[] | .headRefName | select(test(\"^$PREFIX\"))"
    gh pr list --json headRefName --jq "$FILTER"
}

compare_versions(){
    local major1 minor1 patch1
    local major2 minor2 patch2
    IFS='.' read -r major1 minor1 patch1 < <(echo "${1#v}")
    IFS='.' read -r major2 minor2 patch2 < <(echo "${2#v}")

    local diff_major=$(("$major1" - "$major2"))
    local diff_minor=$(("$minor1" - "$minor2"))
    local diff_patch=$(("$patch1" - "$patch2"))

    if ! [ "$diff_major" -eq 0 ]; then
        echo "$diff_major"
    elif ! [ "$diff_minor" -eq 0 ]; then
        echo "$diff_minor"
    else
        echo "$diff_patch"
    fi
}

read_args "$@"

for branch in $(retrieve_prs); do
    branch_version=${branch#"$PREFIX"}
    if [ "$(compare_versions "$branch_version" "$VERSION")" -lt 0 ]; then
        info "close $branch"
        gh pr close "$branch"
    fi
done
