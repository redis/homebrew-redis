[![Protected by Tracebit Community Edition](.github/assets/tracebit-badge.svg)](https://community.tracebit.com/supplychainattacks)

## Recommended: Install using the Homebrew Core Formula

The `redis` formula in homebrew-core now ships Redis Open Source with its modules (Redis Query Engine, JSON, Probabilistic, Time Series), so it is the recommended way to install Redis on macOS:

```bash
brew install redis
```

See the [Redis installation docs for Homebrew](https://redis.io/docs/latest/operate/oss_and_stack/install/install-stack/homebrew/) for details.

## Redis Open Source - Install using Homebrew Cask

This cask was created to ship Redis Open Source with its modules on macOS. The official homebrew-core `redis` formula now supports this, so we recommend installing it with `brew install redis` instead. If you already use the cask, switch to the formula with:

```bash
brew uninstall --cask redis
brew install redis
```

To install Redis Open Source using Homebrew Cask, use the following command:

```bash
brew tap redis/redis
# brew trust is required on Homebrew 6.0+
brew trust redis/redis
brew install --cask redis
```

For pre-release versions, you can use the following command. Note that this will install the latest pre-release version and override the stable version:

```bash
brew tap redis/redis
# brew trust is required on Homebrew 6.0+
brew trust redis/redis
brew install --cask redis-rc
```

#### Note: Configuration File Conflicts
If you previously installed Redis using the standard Homebrew formula `brew install redis` and later removed it, the configuration file may still remain at `$(brew --prefix)/etc/redis.conf`. When installing Redis via the cask method `brew install --cask redis`, this existing configuration file will not be automatically replaced.
To avoid potential conflicts or unexpected behavior, ensure you remove any leftover configuration files from previous Redis installations before installing the cask version

## Supported Operating Systems

Redis officially tests the latest version of this distribution against the following OSes:

- macOS 26 (Tahoe)
- macOS 15 (Sequoia)

macOS 14 (Sonoma) is no longer supported, since Homebrew no longer provides bottles for it.

## Starting Redis

After installation, you can start Redis in the background using the following command:

```bash
redis-server $(brew --prefix)/etc/redis.conf
```



To stop the service:

```bash
redis-cli shutdown
```
