## Redis Open Source - Install using Homebrew Cask

To install the latest version of Redis Open Source using Homebrew Cask, please use the following command:

```bash
brew tap redis/redis
brew install --cask redis
```

For pre-release versions, you can use the following command. Note that this will install the latest pre-release version and override the stable version:

```bash
brew tap redis/redis
brew install --cask redis-rc
```

#### Note: Configuration File Conflicts
If you previously installed Redis using the standard Homebrew formula `brew install redis` and later removed it, the configuration file may still remain at `$(brew --prefix)/etc/redis.conf`. When installing Redis via the cask method `brew install --cask redis`, this existing configuration file will not be automatically replaced.
To avoid potential conflicts or unexpected behavior, ensure you remove any leftover configuration files from previous Redis installations before installing the cask version

## Supported Operating Systems

Redis officially tests the latest version of this distribution against the following OSes:

- macOS 15 (Sequoia)
- macOS 14 (Sonoma)
- macOS 13 (Ventura)

## Starting Redis

After installation, you can start Redis in the background using the following command:

```bash
redis-server $(brew --prefix)/etc/redis.conf
```



To stop the service:

```bash
redis-cli shutdown
```
