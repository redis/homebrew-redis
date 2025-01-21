# Redis Community Edition Homebrew Cask

This repository provides a Homebrew Cask for installing the Redis Community Edition binary distribution.

## Installation

To install Redis Community Edition using Homebrew Cask, run the following command:

```bash
brew tap redis/redis
brew install --cask redis
```

For pre-release versions, you can use the following command. Note that this will install the latest pre-release version and override the stable version:

```bash
brew tap redis/redis
brew install --cask redis-rc
```

## Usage

After installation, you can start Redis using the following command:

```bash
redis-server
```

If you want to start Redis in the background, you can use the following command:

```bash
redis-server $(homebrew --prefix)/etc/redis.conf
```

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request.
