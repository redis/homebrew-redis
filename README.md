## Redis Community Edition - Install using Homebrew Cask

To install the latest version of Redis Community Edition using Homebrew Cask, please use the following command:

```bash
brew tap redis/redis
brew install --cask redis
```

For pre-release versions, you can use the following command. Note that this will install the latest pre-release version and override the stable version:

```bash
brew tap redis/redis
brew install --cask redis-rc
```

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
