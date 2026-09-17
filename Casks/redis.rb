cask "redis" do
  arch arm: "arm64", intel: "x86_64"

  version "8.10.2"
  sha256 arm: "58023ce2a4c7a5c2b1e2f46c443c4ac160b207fe11d5e4f846ab995ca392e436",
         intel: "08334ca85583bc81323be65d22455b0d36d21c3e149c588c911f80284cd8c6b4"

  url "https://packages.redis.io/homebrew/redis-oss-#{version}-#{arch}.zip"
  name "Redis Open Source"
  desc "Redis is an in-memory database that persists on disk. The data model is key-value, but many different kind of values are supported: Strings, Lists, Sets, Sorted Sets, Hashes, Streams, HyperLogLogs, Bitmaps."
  homepage "https://redis.io/"

  depends_on macos: :sonoma

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
    symlink_children "{{caskbase}}/bin/", "{{basepath}}/bin/"

    # link modules
    symlink_children "{{caskbase}}/lib/redis/modules/*.so", "{{HOMEBREW_PREFIX}}/lib/redis/modules"
  end

  uninstall_postflight_steps do
    basepath = HOMEBREW_PREFIX.to_s

    # Remove binary symlinks
    binaries.each do |item|
      dest = "#{basepath}/bin/#{item}"
      File.delete(dest) if File.symlink?(dest) && File.exist?(dest)
    end

    # Remove module symlinks
    moduledir = "#{basepath}/lib/redis/modules"
    Dir["#{moduledir}/*.so"].each do |item|
      module_name = File.basename(item)
      dest = "#{moduledir}/#{module_name}"
      File.delete(dest)
    end

    # Clean up empty directories
    FileUtils.rm_rf(moduledir) if Dir.empty?(moduledir)
    FileUtils.rm_rf("#{basepath}/lib/redis") if Dir.empty?("#{basepath}/lib/redis")
  end

  caveats <<~EOS
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
