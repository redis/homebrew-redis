cask "redis" do
  version "8.10.3"
  sha256 "2d9f2e8940c2117bbecdd25658a2d8813afdbeb9ff24962e88428804831481ec"

  url "https://packages.redis.io/homebrew/redis-oss-#{version}-arm64.zip"
  name "Redis Open Source"
  desc "Redis is an in-memory database that persists on disk. The data model is key-value, but many different kind of values are supported: Strings, Lists, Sets, Sorted Sets, Hashes, Streams, HyperLogLogs, Bitmaps."
  homepage "https://redis.io/"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  depends_on formula: "openssl@3"
  depends_on formula: "libomp"
  depends_on formula: "llvm@18"

  binaries = %w[
    redis-cli
    redis-benchmark
    redis-check-aof
    redis-check-rdb
    redis-sentinel
    redis-server
  ]

  postflight_steps do
    mkdir_p "{{HOMEBREW_PREFIX}}/etc"
    mkdir_p "{{HOMEBREW_PREFIX}}/lib/redis/modules"

    unless_path_exists "{{HOMEBREW_PREFIX}}/etc/redis.conf" do
      copy "{{caskbase}}/etc/redis.conf", "{{HOMEBREW_PREFIX}}/etc/redis.conf", overwrite: false
    end

    # link binaries
    symlink_children "{{caskbase}}/bin/", "{{HOMEBREW_PREFIX}}/bin/", remove_on_uninstall: true

    # link modules
    symlink_children "{{caskbase}}/lib/redis/modules/*.so", "{{HOMEBREW_PREFIX}}/lib/redis/modules", remove_on_uninstall: true
  end

  uninstall_postflight_steps do

    remove "{{HOMEBREW_PREFIX}}/lib/redis/"
  end

  caveats <<~EOS
    The official homebrew-core redis formula now ships Redis Open Source with its
    modules, and is the recommended way to install Redis. To switch to it, run:
      brew uninstall --cask redis
      brew install redis
    See https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/homebrew/

    Redis Open Source has been successfully installed!

    The default configuration file has been copied to:
      #{HOMEBREW_PREFIX}/etc/redis.conf

    To customize Redis, edit this file as needed and restart Redis to apply changes.

    If you want to run Redis as a service, use:
      redis-server #{HOMEBREW_PREFIX}/etc/redis.conf

    To stop the service:
      redis-cli shutdown
  EOS
end
