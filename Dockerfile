FROM debian:bookworm-slim

ARG UID=1001
ARG GID=1001

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND noninteractive

RUN groupadd --gid ${GID} bitcoin \
  && useradd --create-home --no-log-init -u ${UID} -g ${GID} bitcoin \
  && apt-get update -y \
  && apt-get --no-install-recommends -y install curl gnupg gosu ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG BUILD_RUN=0
ARG BUILD_DATE=""
ARG TARGETPLATFORM

ENV BITCOIN_VERSION=25.0
ENV BITCOIN_RC=rc2
ARG BITCOIN_BASE=${BITCOIN_VERSION}${BITCOIN_RC}
ENV BITCOIN_DATA=/home/bitcoin/.bitcoin
ENV PATH=/opt/bitcoin-${BITCOIN_BASE}/bin:$PATH
ARG KEY_URL=https://raw.githubusercontent.com/bitcoin-core/guix.sigs/main/builder-keys

LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.revision=${BUILD_RUN}
LABEL org.opencontainers.image.version=${BITCOIN_BASE}
LABEL org.opencontainers.image.source=https://github.com/dobtc/docker-bitcoin/
LABEL org.opencontainers.image.url=https://hub.docker.com/r/dobtc/docker-bitcoin/

RUN set -ex \
  && if [ -n "${BITCOIN_RC}" ]; then export SUBDIR=/test.; else export SUBDIR=; fi \
  && export URL=https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}${SUBDIR}${BITCOIN_RC} \
  && if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then export TARGETPLATFORM=x86_64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then export TARGETPLATFORM=aarch64-linux-gnu; fi \
  && if [ "${TARGETPLATFORM}" = "linux/arm/v7" ]; then export TARGETPLATFORM=arm-linux-gnueabihf; fi \
  && curl -sSL ${KEY_URL}/CoinForensics.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/Emzy.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/Sjors.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/TheCharlatan.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/achow101.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/benthecarman.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/cfields.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/darosior.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/dunxen.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/fanquake.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/glozow.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/guggero.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/hebasto.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/jackielove4u.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/josibake.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/laanwj.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/satsie.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/sipa.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/svanstaa.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/theStack.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/vertiond.gpg | gpg --import - && \

  && curl -sSL ${KEY_URL}/willyko.gpg | gpg --import - && \

  && curl -SLO ${URL}/bitcoin-${BITCOIN_BASE}-${TARGETPLATFORM}.tar.gz \
  && curl -SLO ${URL}/SHA256SUMS \
  && curl -SLO ${URL}/SHA256SUMS.asc \
  && gpg --verify SHA256SUMS.asc SHA256SUMS \
  && grep " bitcoin-${BITCOIN_BASE}-${TARGETPLATFORM}.tar.gz" SHA256SUMS | sha256sum -c - \
  && tar -xzf *.tar.gz -C /opt \
  && rm *.tar.gz *.asc \
  && rm -rf /opt/bitcoin-${BITCOIN_BASE}/bin/bitcoin-qt \
  && rm -rf /opt/bitcoin-${BITCOIN_BASE}/bin/test_bitcoin
  
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/home/bitcoin/.bitcoin"]

# REST interface
EXPOSE 8080

# P2P network (mainnet, testnet & regnet respectively)
EXPOSE 8333 18333 18444

# RPC interface (mainnet, testnet & regnet respectively)
EXPOSE 8332 18332 18443

# ZMQ ports (for transactions & blocks respectively)
EXPOSE 28332 28333

ENTRYPOINT ["/entrypoint.sh"]

RUN bitcoind -version | grep "Bitcoin Core version v${BITCOIN_VERSION}"

CMD ["bitcoind"]
