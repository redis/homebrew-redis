#!/bin/sh

export HOMEBREW_NO_AUTO_UPDATE=1
brew update
brew install coreutils
brew install make
brew install openssl
brew install llvm@18
brew install cmake@3.31.6
brew install gnu-sed
brew install automake
brew install libtool

RUST_INSTALLER=rust-1.80.1-$(if [ "$(uname -m)" = "arm64" ]; then echo "aarch64"; else echo "x86_64"; fi)-apple-darwin
echo "Downloading and installing Rust standalone installer: ${RUST_INSTALLER}"
wget --quiet -O ${RUST_INSTALLER}.tar.xz https://static.rust-lang.org/dist/${RUST_INSTALLER}.tar.xz
tar -xf ${RUST_INSTALLER}.tar.xz
(cd ${RUST_INSTALLER} && sudo ./install.sh)
rm -rf ${RUST_INSTALLER}