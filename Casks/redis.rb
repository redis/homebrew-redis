cask "redis" do
  arch arm: "arm64", intel: "x86_64"

  version "8.0.0"
  sha256 arm: "e215d7df0a6af692b310b95c45b33b0cc5702682ce3245fee691551cd62c3201",
         intel: "15e5d013a3a731a0d3e2323e2bbada7097da7a16e0ce775b24297dd0ecde502a"

  url "https://packages.redis.io/homebrew/redis-ce-#{version}-#{arch}.zip"
  name "Redis Open Source"
  desc "Redis is an in-memory database that persists on disk. The data model is key-value, but many different kind of values are supported: Strings, Lists, Sets, Sorted Sets, Hashes, Streams, HyperLogLogs, Bitmaps."
  homepage "https://redis.io/"

  depends_on macos: ">= :ventura"

  depends_on formula: "openssl@3"
  depends_on formula: "libomp"
  depends_on formula: "llvm@18"
  
  conflicts_with formula: "redis-rc"

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