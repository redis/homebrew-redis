#!/bin/sh

export HOMEBREW_PREFIX="$(brew --prefix)"
export BUILD_WITH_MODULES=yes
export MODULE_VERSION=master
export BUILD_TLS=yes
export DISABLE_WERRORS=yes
PATH="$HOMEBREW_PREFIX/opt/libtool/libexec/gnubin:$HOMEBREW_PREFIX/opt/llvm@18/bin:$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH" # Override macOS defaults.
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
(cd build_dir && zip -r ../unsigned-redis-ce-unstable-$(uname -m).zip .)
