#!/usr/bin/env bash

CDIR="$(cd "$(dirname "$0")" && pwd)"
build_dir=$CDIR/build

readonly PURE_VERSION=v1.23.0

while getopts A:K:q option
do
  case "${option}"
  in
    q) QUIET=1;;
    A) ARCH=${OPTARG};;
    K) KERNEL=${OPTARG};;
  esac
done

rm -rf $build_dir
mkdir -p $build_dir

for f in pluginrc.zsh
do
    cp $CDIR/$f $build_dir/
done

cd $build_dir

[ $QUIET ] && arg_q='-q' || arg_q=''

if [ -x "$(command -v git)" ]; then
    echo "[info] install Pure ${PURE_VERSION}"
    # do not show detached head warning
    # shellcheck disable=SC2086
    git clone $arg_q --depth 1 --branch "$PURE_VERSION" https://github.com/sindresorhus/pure.git "$build_dir/pure" 2>/dev/null
else
    echo Install git
    exit 1
fi
