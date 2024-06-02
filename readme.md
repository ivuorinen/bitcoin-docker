<h1 align="center">Bitcoin Core<br/>
<div align="center">
<a href="https://github.com/ivuotinen/bitcoin-docker"><img src="https://raw.githubusercontent.com/ivuorinen/bitcoin-docker/master/.github/logo.png" title="Logo" style="max-width:100%;" width="128" /></a>
</div>
<div align="center">

[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Pulls]][hub_url]

</div></h1>

A docker image of Bitcoin Core with support for the following platforms:

- `amd64` (x86_64)
- `arm32v7` (armv7)
- `arm64` (aarch64, armv8)

## Usage

Via Docker Compose:

```yaml
services:
  bitcoin:
    container_name: bitcoin
    image: ivuorinen/bitcoin-docker:latest
    ports:
      - 8332:8332
      - 8333:8333
    volumes:
      - /opt/bitcoin:/home/bitcoin/.bitcoin
```

Via Docker CLI:

```bash
docker run -it --rm ivuorinen/bitcoin-docker -printtoconsole
```

Executing `getinfo` on the running container:

```bash
docker exec --user bitcoin bitcoin bitcoin-cli -getinfo
```

## Stars

[![Stars](https://starchart.cc/ivuorinen/bitcoin-docker.svg?variant=adaptive)](https://starchart.cc/ivuorinen/bitcoin-docker)

[build_url]: https://github.com/ivuorinen/bitcoin-docker/
[hub_url]: https://hub.docker.com/r/ivuorinen/bitcoin-docker
[tag_url]: https://hub.docker.com/r/ivuorinen/bitcoin-docker/tags
[Build]: https://github.com/ivuorinen/bitcoin-docker/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/ivuorinen/bitcoin-docker/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/ivuorinen/bitcoin-docker.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/ivuorinen/bitcoin-docker/latest?arch=amd64&sort=semver&color=066da5
