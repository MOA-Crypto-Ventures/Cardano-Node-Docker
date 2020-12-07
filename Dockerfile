# adapted from https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/000_install.md
FROM ubuntu:focal
LABEL MAINTAINER sstolz
LABEL description="cardano-node and cardano-cli"

ARG ver="tags/1.23.0"
ENV CNVERSION=${ver}

# mainnet or testnet
ARG net="mainnet" 
ENV NETWORK=${net}

ENV SUDO="N"
ENV UPDATE_CHECK='N'
ENV BOOTSTRAP_HASKELL_NO_UPGRADE=1

RUN mkdir -p ~/.local/bin

ENV LANG=C.UTF-8
ENV USER=root
ENV DEBIAN_FRONTEND=noninteractive

ENV CNODE_HOME="/opt/cardano/cnode"
ENV PATH="/root/.cargo/bin:/root/.ghcup/bin:$PATH:$CNODE_HOME/scripts:/root/.cabal/bin"
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV CARDANO_NODE_SOCKET_PATH="${CNODE_HOME}/sockets/node0.socket"

# guild-operators prereqs.sh
ARG guild_ver="alpha"
ENV BRANCH=${guild_ver}
RUN set -x && apt-get update \
  && mkdir -p /root/.cabal/bin && mkdir -p /root/.ghcup/bin \
  && apt-get install -y bsdmainutils sudo apt-utils wget gnupg apt-utils git \
  && apt-get install -y curl original-awk bsdmainutils sudo \
  && apt-get install -y libpq-dev python3 build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev systemd libsystemd-dev libsodium-dev zlib1g-dev make g++ tmux git jq libncursesw5 gnupg aptitude libtool autoconf secure-delete iproute2 bc tcptraceroute dialog sqlite libsqlite3-dev \
  && wget https://raw.githubusercontent.com/cardano-community/guild-operators/${BRANCH}/scripts/cnode-helper-scripts/prereqs.sh \
  #&& export SUDO='N' \
  #&& export UPDATE_CHECK='N' \
  #&& export BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
  && chmod +x ./prereqs.sh &&  ./prereqs.sh 

# install cardano-node and cardano-cli
RUN git clone https://github.com/input-output-hk/cardano-node.git \
  && export BOOTSTRAP_HASKELL_NO_UPGRADE=1 \
  && wget https://raw.githubusercontent.com/stakelovelace/cardano-htn/master/release-versions/cardano-node-latest.txt \
  && CNVERSION=$(cat cardano-node-latest.txt) \
  && cd cardano-node \
  && echo "package cardano-crypto-praos" > cabal.project.local \
  && echo "   flags: -external-libsodium-vrf" >> cabal.project.local \
  && git fetch --tags --all && git checkout tags/$CNVERSION \
  && bash $CNODE_HOME/scripts/cabal-build-all.sh \
  && apt-get -y remove libpq-dev build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ && apt-get -y purge && apt-get -y clean && apt-get -y autoremove \
  && cardano-node --version; 

# install cardano-node and cardano-cli
# RUN echo ${PATH} && \
#     apt-get update -y && \
#     export DEBIAN_FRONTEND=noninteractive && \
#     ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
# # install tools needed for cntools
#     apt-get install -y curl original-awk bsdmainutils sudo && \
#     apt-get install -y libpq-dev python3 build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev systemd libsystemd-dev libsodium-dev zlib1g-dev make g++ tmux git jq libncursesw5 gnupg aptitude libtool autoconf secure-delete iproute2 bc tcptraceroute dialog sqlite libsqlite3-dev && \
# # compile and install tools for cardano compiling
#     apt-get install -y tzdata && \
#     dpkg-reconfigure --frontend noninteractive tzdata && \
#     apt-get install -y bc net-tools build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf && \
#     #apt-get clean && \
#     #apt-get autoremove --yes && \
#     #rm -rf /var/lib/apt/lists/* && \
#     cd && \
#     wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz && \
#     tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz && \
#     rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig && \
#     mv cabal /root/.local/bin/ && \
#     echo ${PATH} && \
#     ls -l /root/.local/bin/ && \
#     cabal update && \
#     wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz && \
#     tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz && \
#     rm ghc-8.6.5-x86_64-deb9-linux.tar.xz && \
#     cd ghc-8.6.5 && \
#     ./configure && \
#     make install && \
#     cd .. && \
#     git clone https://github.com/input-output-hk/libsodium  && \
#     cd libsodium  && \
#     git checkout 66f017f1  && \
#     ./autogen.sh  && \
#     ./configure  && \
#     make  && \
#     make install
# RUN git clone https://github.com/input-output-hk/cardano-node.git  && \
#     cd cardano-node && \
#     git checkout ${CNVERSION} && \
#     cabal build cardano-node cardano-cli && \
#     cabal install cardano-node cardano-cli

## Install guild-operator scripts

# alpha until SUDO switch prereqs.sh in master
# ARG guild_ver="alpha"
# ENV ENV_GUILD_VER=${guild_ver}

# RUN mkdir -p ${CNODE_HOME}/scripts
# RUN mkdir -p ${CNODE_HOME}/guild-db
# RUN mkdir -p ${CNODE_HOME}/logs
# RUN git clone https://github.com/cardano-community/guild-operators.git  && \
#     cd guild-operators && \
#     git checkout ${ENV_GUILD_VER}  && \
#     mv ./scripts/cnode-helper-scripts/* ${CNODE_HOME}/scripts && \
#     cd / && rm -rf guild-operators
# RUN sed -i '/^#SOCKET=.* /s/^#//' ${CNODE_HOME}/scripts/env

## Get config files



# RUN mkdir -p ${CNODE_HOME}/files
# RUN mkdir -p ${CNODE_HOME}/sockets
# WORKDIR ${CNODE_HOME}/files
# RUN pwd
# RUN curl -o config.json https://hydra.iohk.io/build/4805432/download/1/${NETWORK}-config.json 
# RUN curl -O https://hydra.iohk.io/build/4805432/download/1/${NETWORK}-byron-genesis.json && \
#     curl -O https://hydra.iohk.io/build/4805432/download/1/${NETWORK}-shelley-genesis.json && \
#     curl -o topology.json https://hydra.iohk.io/build/4805432/download/1/${NETWORK}-topology.json && \
#     curl -O https://hydra.iohk.io/build/4805432/download/1/${NETWORK}-db-sync-config.json && \
#     curl -O https://hydra.iohk.io/build/4805432/download/1/rest-config.json

WORKDIR ${CNODE_HOME}

ENTRYPOINT [ "cardano-node", "run", \
                "--config", "/opt/cardano/cnode/files/config.json", \
                "--topology", "/opt/cardano/cnode/files/topology.json", \
                "--database-path", "/opt/cardano/cnode/db", \
                "--socket-path", "/opt/cardano/cnode/sockets/node0.socket" \
            ]