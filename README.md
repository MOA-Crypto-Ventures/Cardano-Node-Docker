# Cardano-Node-Docker

Cardano node Docker version to be flexible, fast and safe in deployment.

## Introduction

This `Dockerfile` compiles cardano-node and cardano-cli. You will need **Cardano Stake Pool Operator** skills as well as basic Bash and Docker skills. The `docker-compose.yml` file contains all instructions to build the image and run the container. It is suited for a relay node. Feel free to copy it and adopt the run command for the block producing node. 

## How to setup

1. Change docker-compose.yml to your needs. If you create a folder "config", "data" and "ipc" in the folder of docker-compose.yml, all should be perfect. You have just to change "your.ip" to match you public IP.
2. Download Topology/config files from [hydra.iohk.io](https://hydra.iohk.io/build/3624229/download/1/index.html) and put them into the "config" folder
3. `docker-compose up` will build with instructions from Dockerfile and run the node

## Example for using the node

I hope this example will help coders with basic docker skills. 

I assume you want to use [gitmachtl/scripts](https://github.com/gitmachtl/scripts/tree/master/cardano/mainnet). If your Docker container is already running, edit [00_common.sh](https://github.com/gitmachtl/scripts/blob/master/cardano/mainnet/00_common.sh) and change following lines. You have to adjust the path to your needs:

```bash
#!/bin/bash

socket="/path/to/docker-compos.yml/ipc/node.socket"

genesisfile="/path/to/docker-compos.yml/config/mainnet_candidate_4-shelley-genesis.json"           #Shelley
genesisfile_byron="/path/to/docker-compos.yml/config/mainnet_candidate_4-byron-genesis.json"       #Byron

cardanocli="docker exec -w /data -i cardano cardano-cli"
cardanonode="docker exec -w /data -i cardano cardano-node"

magicparam="--testnet-magic 42"

[...]

tempDir="./tmp"
```

It is now important, that you put the path of the scripts into your PATH:

```
PATH=/path/to/script/executables:$PATH
```

and then execute the scripts from your "data" path. Also create a "./tmp" folder in "data".

To adapt it to other use cases, look at the commands `docker exec -w /data -i cardano cardano-cli` and `docker exec -w /data -i cardano cardano-node`. This is how you can call the executables from outside the container. 
