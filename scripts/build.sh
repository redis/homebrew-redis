#!/bin/sh

export HOMEBREW_PREFIX="$(brew --prefix)"
export BUILD_WITH_MODULES=yes
export BUILD_TLS=yes
export DISABLE_WERRORS=yes
PATH="$HOMEBREW_PREFIX/opt/libtool/libexec/gnubin:$HOMEBREW_PREFIX/opt/llvm@18/bin:$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH" # Override macOS defaults.
export LDFLAGS="-L$HOMEBREW_PREFIX/opt/llvm@18/lib"
export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/llvm@18/include"

# Check if Redis version is provided as an argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <redis_version>"
  exit 1
fi

REDIS_VERSION="$1"

curl -L "https://github.com/redis/redis/archive/refs/tags/$REDIS_VERSION.tar.gz" -o redis.tar.gz
tar xzf redis.tar.gz

mkdir -p build_dir/etc
make -C redis-$REDIS_VERSION -j "$(nproc)" all OS=macos
make -C redis-$REDIS_VERSION install PREFIX=$(pwd)/build_dir OS=macos
cp ./configs/redis.conf build_dir/etc/redis.conf
(cd build_dir && zip -r ../redis-oss-$REDIS_VERSION-$(uname -m).zip .)
