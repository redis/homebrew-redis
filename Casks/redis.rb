cask "redis" do
  arch arm: "arm64", intel: "x86_64"

  version "8.10.1"
  sha256 arm: "3e7966a847255580f93fac2398d99c20d80583decf10f194b60fe20a7724e433",
         intel: "e1f569987b20ddf3948476a9c39e9706a2f0823c6990cc14a683a968cd6c9fb3"

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
