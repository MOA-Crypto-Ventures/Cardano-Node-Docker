# adapted from https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/000_install.md
FROM ubuntu:focal
LABEL MAINTAINER sstolz
LABEL description="cardano-node and cardano-cli"

ARG VER="tags/1.21.1"
ENV ENV_VER=${VER}

RUN mkdir -p ~/.local/bin

RUN mkdir -p /configuration
COPY ./configuration-mainnet /configuration-mainnet
COPY ./configuration-testnet /configuration-testnet


ENV PATH="/root/.cabal/bin:/root/.local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV CARDANO_NODE_SOCKET_PATH="/ipc/node.socket"

RUN echo ${PATH} && \
    apt update -y && \
    export DEBIAN_FRONTEND=noninteractive && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt install -y bc net-tools build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf && \
    cd && \
    wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz && \
    tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz && \
    rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig && \
    mv cabal /root/.local/bin/ && \
    echo ${PATH} && \
    ls -l /root/.local/bin/ && \
    cabal update && \
    wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz && \
    tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz && \
    rm ghc-8.6.5-x86_64-deb9-linux.tar.xz && \
    cd ghc-8.6.5 && \
    ./configure && \
    make install && \
    cd .. && \
    git clone https://github.com/input-output-hk/libsodium  && \
    cd libsodium  && \
    git checkout 66f017f1  && \
    ./autogen.sh  && \
    ./configure  && \
    make  && \
    make install  && \
    git clone https://github.com/input-output-hk/cardano-node.git  && \
    cd cardano-node && \
    git checkout ${ENV_VER} && \
    cabal build cardano-node cardano-cli && \
    cabal install cardano-node cardano-cli
WORKDIR /data
# ENTRYPOINT ["cardano-node"]