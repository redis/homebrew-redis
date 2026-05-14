#!/bin/sh

set -e

export HOMEBREW_NO_AUTO_UPDATE=1
brew update
brew install coreutils
brew install make
brew install llvm@18
brew install gnu-sed
brew install automake
brew install libtool

# Ensure Homebrew's cmake does not interfere
brew uninstall --ignore-dependencies cmake || true

# Clean up any stale CMake symlinks
rm -f /usr/local/bin/cmake
rm -f /usr/local/bin/ctest
rm -f /usr/local/bin/cpack

CMAKE_VERSION=3.31.6
mkdir ~/Downloads/CMake
curl --location --retry 3 "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-macos-universal.dmg" --output ~/Downloads/CMake/cmake-macos.dmg
hdiutil attach -mountpoint /Volumes/cmake-macos ~/Downloads/CMake/cmake-macos.dmg
cp -R /Volumes/cmake-macos/CMake.app /Applications/
hdiutil detach /Volumes/cmake-macos
sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install=/usr/local/bin
cmake --version

RUST_INSTALLER=rust-1.80.1-$(if [ "$(uname -m)" = "arm64" ]; then echo "aarch64"; else echo "x86_64"; fi)-apple-darwin
echo "Downloading and installing Rust standalone installer: ${RUST_INSTALLER}"
wget --quiet -O ${RUST_INSTALLER}.tar.xz https://static.rust-lang.org/dist/${RUST_INSTALLER}.tar.xz
tar -xf ${RUST_INSTALLER}.tar.xz
(cd ${RUST_INSTALLER} && sudo ./install.sh)
rm -rf ${RUST_INSTALLER}
