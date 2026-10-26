cask "redis-rc" do
  version "8.10.3"
  sha256 "2d9f2e8940c2117bbecdd25658a2d8813afdbeb9ff24962e88428804831481ec"

  url "https://packages.redis.io/homebrew/redis-oss-#{version}-arm64.zip"
  name "Redis Open Source - Pre-Release"
  desc "THIS IS A PRE-RELEASE VERSION!! BREAKING CHANGES MAY OCCUR WITHOUT NOTICE!! Redis is an in-memory database that persists on disk. The data model is key-value, but many different kind of values are supported: Strings, Lists, Sets, Sorted Sets, Hashes, Streams, HyperLogLogs, Bitmaps."
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
  
  postflight do
    basepath = HOMEBREW_PREFIX.to_s
    caskbase = "#{caskroom_path}/#{version}"
    confdir = "#{basepath}/etc"
    moduledir = "#{basepath}/lib/redis/modules"

    FileUtils.mkdir_p(confdir)
    FileUtils.mkdir_p(moduledir)

    # Replace <HOMEBREW_PREFIX> with the actual value
    src = "#{caskbase}/etc/redis.conf"
    conffile = "#{confdir}/redis.conf"
    FileUtils.cp(src, conffile) unless File.exist?(conffile)
    text = File.read(conffile)
    new_contents = text.gsub("<HOMEBREW_PREFIX>", basepath)
    File.open(conffile, "w") { |file| file.puts new_contents }

    # link binaries
    binaries.each do |item|
      src = "#{caskbase}/bin/#{item}"
      dest = "#{basepath}/bin/#{item}"
      FileUtils.ln_sf(src, dest)
    end

    # link modules
    Dir["#{caskbase}/lib/redis/modules/*.so"].each do |item|
      module_name = File.basename(item)
      dest = "#{moduledir}/#{module_name}"
      File.symlink(item, dest) unless File.exist?(dest)
    end
  end

  uninstall_postflight do
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
    🚨THIS IS A PRE-RELEASE VERSION!! BREAKING CHANGES MAY OCCUR WITHOUT NOTICE!!🚨

    The official homebrew-core redis formula now ships Redis Open Source with its
    modules, and is the recommended way to install Redis (stable releases only).
    To switch to it, run:
      brew uninstall --cask redis-rc
      brew install redis
    See https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/homebrew/

    Redis Community Edition has been successfully installed!

    The default configuration file has been copied to:
      #{HOMEBREW_PREFIX}/etc/redis.conf

    To customize Redis, edit this file as needed and restart Redis to apply changes.

    If you want to run Redis as a service, use:
      redis-server #{HOMEBREW_PREFIX}/etc/redis.conf

    To stop the service:
      redis-cli shutdown
  EOS
end
