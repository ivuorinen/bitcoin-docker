# docker-bitcoin

[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Pulls]][hub_url]

[build_url]: https://github.com/kroese/docker-bitcoin/
[hub_url]: https://hub.docker.com/r/kroese/docker-bitcoin
[tag_url]: https://hub.docker.com/r/kroese/docker-bitcoin/tags

[Build]: https://github.com/kroese/docker-bitcoin/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/kroese/docker-bitcoin/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/kroese/docker-bitcoin.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/kroese/docker-bitcoin?arch=amd64&sort=semver&color=066da5

A docker image of Bitcoin Core with support for the following platforms:

* `amd64` (x86_64)
* `arm32v7` (armv7)
* `arm64` (aarch64, armv8)

## Tags

- `24.0.1`, `24`, `latest` ([24/Dockerfile](https://github.com/kroese/docker-bitcoin/blob/master/24/Dockerfile)) [**multi-arch**]
- `24.0.1-alpine`, `24-alpine` ([24/alpine/Dockerfile](https://github.com/kroese/docker-bitcoin/blob/master/24/alpine/Dockerfile))

- `23.0`, `23` ([23/Dockerfile](https://github.com/kroese/docker-bitcoin/blob/master/23/Dockerfile)) [**multi-arch**]
- `23.0-alpine`, `23-alpine` ([23/alpine/Dockerfile](https://github.com/kroese/docker-bitcoin/blob/master/23/alpine/Dockerfile))

- `22.0`, `22`, ([22/Dockerfile](https://github.com/kroese/docker-bitcoin/blob/master/22/Dockerfile)) [**multi-arch**]
- `22.0-alpine`, `22-alpine` ([22/alpine/Dockerfile](https://github.com/kroese/docker-bitcoin/blob/master/22/alpine/Dockerfile))

**Multi-architecture builds**

The newest images (Debian-based, *0.19+*) provide built-in support for multiple architectures. Running `docker pull` on any of the supported platforms will automatically choose the right image for you as all of the manifests and artifacts are pushed to the Docker registry.

**Picking the right tag**

- `kroese/docker-bitcoin:latest`: points to the latest stable release available of Bitcoin Core. Caution when using in production as blindly upgrading Bitcoin Core is a risky procedure.
- `kroese/docker-bitcoin:alpine`: same as above but using the Alpine Linux distribution (a resource efficient Linux distribution with security in mind, but not officially supported by the Bitcoin Core team — use at your own risk).
- `kroese/docker-bitcoin:<version>`: based on a slim Debian image, this tag format points to a specific version branch (e.g. `0.20`) or release of Bitcoin Core (e.g. `0.20.1`). Uses the pre-compiled binaries which are distributed by the Bitcoin Core team.
- `kroese/docker-bitcoin:<version>-alpine`: same as above but using the Alpine Linux distribution.

## What is Bitcoin Core?

Bitcoin Core is a reference client that implements the Bitcoin protocol for remote procedure call (RPC) use. It is also the second Bitcoin client in the network's history. Learn more about Bitcoin Core on the [Bitcoin Developer Reference docs](https://bitcoin.org/en/developer-reference).

## Usage

### How to use this image

This image contains the main binaries from the Bitcoin Core project - `bitcoind`, `bitcoin-cli` and `bitcoin-tx`. It behaves like a binary, so you can pass any arguments to the image and they will be forwarded to the `bitcoind` binary:

```sh
❯ docker run --rm -it kroese/docker-bitcoin \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

_Note: [learn more](#using-rpcauth-for-remote-authentication) about how `-rpcauth` works for remote authentication._

By default, `bitcoind` will run as user `bitcoin` in the group `bitcoin` for security reasons and with its default data dir set to `~/.bitcoin`. If you'd like to customize where `docker-bitcoin` stores its data, you must use the `BITCOIN_DATA` environment variable. The directory will be automatically created with the correct permissions for the `bitcoin` user and `bitcoind` automatically configured to use it.

```sh
❯ docker run --env BITCOIN_DATA=/var/lib/docker-bitcoin --rm -it kroese/docker-bitcoin \
  -printtoconsole \
  -regtest=1
```

You can also mount a directory in a volume under `/home/bitcoin/.bitcoin` in case you want to access it on the host:

```sh
❯ docker run -v ${PWD}/data:/home/bitcoin/.bitcoin -it --rm kroese/docker-bitcoin \
  -printtoconsole \
  -regtest=1
```

You can optionally create a service using `docker-compose`:

```yml
docker-bitcoin:
  image: kroese/docker-bitcoin
  command:
    -printtoconsole
    -regtest=1
```

### Using a custom user id (UID) and group id (GID)

By default, images are created with a `bitcoin` user/group using a static UID/GID (`101:101` on Debian and `100:101` on Alpine). You may customize the user and group ids using the build arguments `UID` (`--build-arg UID=<uid>`) and `GID` (`--build-arg GID=<gid>`).

If you'd like to use the pre-built images, uou can also customize the UID/GID on runtime via environment variables `$UID` and `$GID`:

```sh
❯ docker run -e UID=10000 -e GID=10000 -it --rm kroese/docker-bitcoin \
  -printtoconsole \
  -regtest=1
```

This will recursively change the ownership of the `bitcoin` home directory and `$BITCOIN_DATA` to UID/GID `10000:10000`.

### Using RPC to interact with the daemon

There are two communications methods to interact with a running Bitcoin Core daemon.

The first one is using a cookie-based local authentication. It doesn't require any special authentication information as running a process locally under the same user that was used to launch the Bitcoin Core daemon allows it to read the cookie file previously generated by the daemon for clients. The downside of this method is that it requires local machine access.

The second option is making a remote procedure call using a username and password combination. This has the advantage of not requiring local machine access, but in order to keep your credentials safe you should use the newer `rpcauth` authentication mechanism.

#### Using cookie-based local authentication

Start by launch the Bitcoin Core daemon:

```sh
❯ docker run --rm --name bitcoin-server -it kroese/docker-bitcoin \
  -printtoconsole \
  -regtest=1
```

Then, inside the running `bitcoin-server` container, locally execute the query to the daemon using `bitcoin-cli`:

```sh
❯ docker exec --user bitcoin bitcoin-server bitcoin-cli -regtest getmininginfo

{
  "blocks": 0,
  "currentblocksize": 0,
  "currentblockweight": 0,
  "currentblocktx": 0,
  "difficulty": 4.656542373906925e-10,
  "errors": "",
  "networkhashps": 0,
  "pooledtx": 0,
  "chain": "regtest"
}
```

In the background, `bitcoin-cli` read the information automatically from `/home/bitcoin/.bitcoin/regtest/.cookie`. In production, the path would not contain the regtest part.

#### Using rpcauth for remote authentication

Before setting up remote authentication, you will need to generate the `rpcauth` line that will hold the credentials for the Bitcoind Core daemon. You can either do this yourself by constructing the line with the format `<user>:<salt>$<hash>` or use the official [`rpcauth.py`](https://github.com/bitcoin/bitcoin/blob/master/share/rpcauth/rpcauth.py)  script to generate this line for you, including a random password that is printed to the console.

_Note: This is a Python 3 script. use `[...] | python3 - <username>` when executing on macOS._

Example:

```sh
❯ curl -sSL https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py | python - <username>

String to be appended to bitcoin.conf:
rpcauth=foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc
Your password:
qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=
```

Note that for each run, even if the username remains the same, the output will be always different as a new salt and password are generated.

Now that you have your credentials, you need to start the Bitcoin Core daemon with the `-rpcauth` option. Alternatively, you could append the line to a `bitcoin.conf` file and mount it on the container.

Let's opt for the Docker way:

```sh
❯ docker run --rm --name bitcoin-server -it kroese/docker-bitcoin \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

Two important notes:

1. Some shells require escaping the rpcauth line (e.g. zsh), as shown above.
2. It is now perfectly fine to pass the rpcauth line as a command line argument. Unlike `-rpcpassword`, the content is hashed so even if the arguments would be exposed, they would not allow the attacker to get the actual password.

You can now connect via `bitcoin-cli` or any other [compatible client](https://github.com/kroese/docker-bitcoin). You will still have to define a username and password when connecting to the Bitcoin Core RPC server.

To avoid any confusion about whether or not a remote call is being made, let's spin up another container to execute `bitcoin-cli` and connect it via the Docker network using the password generated above:

```sh
❯ docker run -it --link bitcoin-server --rm kroese/docker-bitcoin \
  bitcoin-cli \
  -rpcconnect=bitcoin-server \
  -regtest \
  -rpcuser=foo\
  -stdinrpcpass \
  getbalance
```

Enter the password `qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=` and hit enter:

```
0.00000000
```

Note: under Bitcoin Core < 0.16, use `-rpcpassword="qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0="` instead of `-stdinrpcpass`.

Done!

### Exposing Ports

Depending on the network (mode) the Bitcoin Core daemon is running as well as the chosen runtime flags, several default ports may be available for mapping.

Ports can be exposed by mapping all of the available ones (using `-P` and based on what `EXPOSE` documents) or individually by adding `-p`. This mode allows assigning a dynamic port on the host (`-p <port>`) or assigning a fixed port `-p <hostPort>:<containerPort>`.

Example for running a node in `regtest` mode mapping JSON-RPC/REST (18443) and P2P (18444) ports:

```sh
docker run --rm -it \
  -p 18443:18443 \
  -p 18444:18444 \
  kroese/docker-bitcoin \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcbind=0.0.0.0 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

To test that mapping worked, you can send a JSON-RPC curl request to the host port:

```
curl --data-binary '{"jsonrpc":"1.0","id":"1","method":"getnetworkinfo","params":[]}' http://foo:qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=@127.0.0.1:18443/
```