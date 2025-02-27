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

- macOS 13
- macOS 14
- macOS 15

## Starting Redis

After installation, you can start Redis using the following command:

```bash
redis-server
```

If you want to start Redis in the background, you can use the following command:

```bash
redis-server $(homebrew --prefix)/etc/redis.conf
```
