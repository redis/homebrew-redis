#!/bin/sh

set -e

export HOMEBREW_PREFIX="$(brew --prefix)"
export BUILD_TLS=yes
# Override RediSearch's new LTO=1 default; toolchain support TBD.
export LTO=0
PATH="$HOMEBREW_PREFIX/opt/llvm@18/bin:$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH" # Override macOS defaults.
export LDFLAGS="-L$HOMEBREW_PREFIX/opt/llvm@18/lib"
export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/llvm@18/include"

# Check if Redis version is provided as an argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 <redis_version>"
  exit 1
fi

REDIS_VERSION="$1"

# Internal releases lack the redis-full archive, fall back to the tag source.
if curl --fail -SsL -o redis.tar.gz "https://github.com/redis/redis/releases/download/$REDIS_VERSION/redis-full.tar.gz"; then
  tar xzf redis.tar.gz
else
  curl --fail -SsL -o redis.tar.gz "https://github.com/redis/redis/archive/refs/tags/$REDIS_VERSION.tar.gz"
  tar xzf redis.tar.gz
  make -C redis-$REDIS_VERSION modules-update MODULES_UPDATE_SHALLOW=1
fi

mkdir -p build_dir/etc
if [ -f "redis-$REDIS_VERSION/modules/modules.yaml" ]; then
  make -C redis-$REDIS_VERSION -j "$(nproc)" deploy PREFIX=$(pwd)/build_dir
else
  export BUILD_WITH_MODULES=yes
  make -C redis-$REDIS_VERSION -j "$(nproc)" all OS=macos
  make -C redis-$REDIS_VERSION install PREFIX=$(pwd)/build_dir OS=macos
fi

# Verify that all required modules were built and installed
echo "Verifying Redis modules..."
MODULES_DIR="build_dir/lib/redis/modules"
REQUIRED_MODULES="redisearch.so rejson.so redisbloom.so redistimeseries.so"
MISSING_MODULES=""

for module in $REQUIRED_MODULES; do
  if [ ! -f "$MODULES_DIR/$module" ]; then
    MISSING_MODULES="$MISSING_MODULES $module"
    echo "ERROR: Module $module not found in $MODULES_DIR"
  else
    echo "Found module: $module"
  fi
done

if [ -n "$MISSING_MODULES" ]; then
  echo ""
  echo "ERROR: Build failed - missing required modules:$MISSING_MODULES"
  echo "Expected modules in: $MODULES_DIR"
  echo "Contents of $MODULES_DIR:"
  ls -la "$MODULES_DIR" 2>/dev/null || echo "Directory does not exist"
  exit 1
fi

cp ./configs/redis.conf build_dir/etc/redis.conf
(cd build_dir && zip -r ../redis-oss-$REDIS_VERSION-$(uname -m).zip .)
