# adapted from https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/000_install.md
FROM ubuntu:focal
LABEL MAINTAINER sstolz
LABEL description="cardano-node and cardano-cli"

ARG NET="mainnet" # mainnet or testnet

ARG VER="tags/1.23.0"
ENV ENV_VER=${VER}

RUN mkdir -p ~/.local/bin

ENV CNODE_HOME="/opt/cardano/cnode"
ENV PATH="/root/.cabal/bin:/root/.local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV CARDANO_NODE_SOCKET_PATH="${CNODE_HOME}/sockets/node0.socket"

# install cardano-node and cardano-cli
RUN echo ${PATH} && \
    apt-get update -y && \
    export DEBIAN_FRONTEND=noninteractive && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime 
# install tools needed for cntools
RUN apt-get install -y curl original-awk bsdmainutils systemd sudo
# compile and install tools for cardano compiling
RUN    apt-get install -y tzdata && \
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
    make install
RUN git clone https://github.com/input-output-hk/cardano-node.git  && \
    cd cardano-node && \
    git checkout ${ENV_VER} && \
    cabal build cardano-node cardano-cli && \
    cabal install cardano-node cardano-cli

## Install guild-operator scripts
RUN mkdir -p ${CNODE_HOME}/scripts
RUN mkdir -p ${CNODE_HOME}/guild-db
RUN mkdir -p ${CNODE_HOME}/logs
RUN git clone https://github.com/cardano-community/guild-operators.git  && \
    cd guild-operators && \
    git checkout master  && \
    mv ./scripts/cnode-helper-scripts/* ${CNODE_HOME}/scripts && \
    cd / && rm -rf guild-operators

## Get config files
RUN mkdir -p ${CNODE_HOME}/files
RUN mkdir -p ${CNODE_HOME}/files-testnet
RUN cd ${CNODE_HOME}/files && \
    wget https://hydra.iohk.io/build/4805432/download/1/${NET}-config.json && \
    wget https://hydra.iohk.io/build/4805432/download/1/${NET}-byron-genesis.json && \
    wget https://hydra.iohk.io/build/4805432/download/1/${NET}-shelley-genesis.json && \
    wget https://hydra.iohk.io/build/4805432/download/1/${NET}-topology.json && \
    wget https://hydra.iohk.io/build/4805432/download/1/${NET}-db-sync-config.json && \
    wget https://hydra.iohk.io/build/4805432/download/1/rest-config.json

RUN mkdir -p ${CNODE_HOME}/data
WORKDIR ${CNODE_HOME}/data
