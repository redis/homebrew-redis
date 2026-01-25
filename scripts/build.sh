#!/bin/sh

set -e

export HOMEBREW_PREFIX="$(brew --prefix)"
export BUILD_WITH_MODULES=yes
export MODULE_VERSION=master
export BUILD_TLS=yes
export DISABLE_WERRORS=yes
PATH="$HOMEBREW_PREFIX/opt/llvm@18/bin:$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH" # Override macOS defaults.
export LDFLAGS="-L$HOMEBREW_PREFIX/opt/llvm@18/lib"
export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/llvm@18/include"

curl -L "https://github.com/redis/redis/archive/refs/heads/unstable.tar.gz" -o redis-unstable.tar.gz
tar xzf redis-unstable.tar.gz

# Update module versions to use master branch
for module in redisbloom redisearch redistimeseries redisjson; do
  if [ -f "redis-unstable/modules/${module}/Makefile" ]; then
    sed -i 's/MODULE_VERSION = .*/MODULE_VERSION = master/' "redis-unstable/modules/${module}/Makefile"
    echo "Updated MODULE_VERSION to master for ${module}"
  fi
done

mkdir -p build_dir/etc
make -C redis-unstable -j "$(nproc)" all OS=macos
make -C redis-unstable install PREFIX=$(pwd)/build_dir OS=macos
cp ./configs/redis.conf build_dir/etc/redis.conf

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

(cd build_dir && zip -r ../unsigned-redis-oss-unstable-$(uname -m).zip .)
