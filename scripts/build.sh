#!/bin/sh

set -e

export HOMEBREW_PREFIX="$(brew --prefix)"
export BUILD_TLS=yes
# Override RediSearch's new LTO=1 default; toolchain support TBD.
export LTO=0
PATH="$HOMEBREW_PREFIX/opt/llvm@18/bin:$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH" # Override macOS defaults.
export LDFLAGS="-L$HOMEBREW_PREFIX/opt/llvm@18/lib"
export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/llvm@18/include"

curl -L "https://github.com/redis/redis/archive/refs/heads/unstable.tar.gz" -o redis-unstable.tar.gz
tar xzf redis-unstable.tar.gz

# Point every module at the master branch in the manifest.
yq -i '.modules[].ref = "master"' redis-unstable/modules/modules.yaml

# Clone the bundled modules (shallow) at the master refs set above.
make -C redis-unstable modules-update MODULES_UPDATE_SHALLOW=1

mkdir -p build_dir/etc
make -C redis-unstable -j "$(nproc)" deploy PREFIX=$(pwd)/build_dir
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
