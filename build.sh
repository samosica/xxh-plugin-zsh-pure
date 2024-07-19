#!/usr/bin/env bash
set -eu

CDIR="$(cd "$(dirname "$0")" && pwd)"
readonly CDIR
readonly build_dir=$CDIR/build
# xxh does not copy files that start with a dot (.)
PURE_VERSION=$(cat "$CDIR/pure-version")
readonly PURE_VERSION

QUIET=""

while getopts A:K:q option; do
    case "${option}" in
        q) QUIET=1;;
        *) ;;
    esac
done

rm -rf "$build_dir"
mkdir -p "$build_dir"
cp "$CDIR/pluginrc.zsh" "$build_dir/"

cd "$build_dir" || exit 1

[ "$QUIET" ] && arg_q='-q' || arg_q=''

if ! command -v git >/dev/null 2>&1; then
    echo "[error] you need to install git"
    exit 1
fi

echo "[info] install Pure ${PURE_VERSION}"
# do not show detached head warning
# shellcheck disable=SC2086
git clone $arg_q --depth 1 --branch "$PURE_VERSION" https://github.com/sindresorhus/pure.git "$build_dir/pure" 2>/dev/null
