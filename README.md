# Cardano-Node-Docker

Cardano node Docker version to be flexible, fast and safe in deployment.

## News

To be more flexible, I **removed the entrypoint**. So keep care to **change your docker-compose.yml and your scripts** with newly pulled images. See the examples below. 

## Introduction

This "Dockerfile" compiles cardano-node and cardano-cli. You will need **Cardano Stake Pool Operator** skills as well as basic Bash and Docker skills. The "docker-compose.yml" file contains all instructions to build the image and run the container. It is suited for a relay node. Feel free to copy it and adopt the run command for the block producing node. 

## Hot to use the image for cardano-cli



## How to setup a Cardano Relay Node with docker-compose.yml

Create a "docker-compose.yml" like the following:

```yml
version: '2'

services:
    cardano-relay-node:
        image: ststolz/cardano-node:latest
        container_name: cardano-relay-node
        network_mode: host
        volumes:
            - ./configuration:/configuration-mainnet
            - ./data:/data
            - ./ipc:/ipc
        command: ["cardano-node", "run", 
                    "--config", "/configuration-mainnet/mainnet-config.json", 
                    "--topology", "/configuration-mainnet/mainnet-topology.json", 
                    "--database-path", "/data/db", 
                    "--port", "7030", 
                    "--host-addr", "x.x.x.x", 
                    "--socket-path", "/ipc/node.socket"]
```

1. Change "x.x.x.x" in "docker-compose.yml" to match public IP.
2. Create a folder "configuration", "data" and "ipc" in the folder containing "docker-compose.yml".
3. Download Topology/config files from [hydra.iohk.io](https://hydra.iohk.io/build/4805432/download/1/index.html) and put them into the "config" folder. Alternatively you can copy the folder "/configuration-mainnet" or "/configuration-testnet" out of the container into local file system.
4. Change into directory containing docker-compose.yml and execute `docker-compose up`. This will pull the image from https://hub.docker.com/ and start the container.

Congrats! Relay Node running!

## How to use with cold storage

Transfer your image to the cold storage by exporting it to an USB drive:

```bash
docker save -o <USB_path/cardano-node-image.tar> ststolz/cardano-node:latest
```

Restore the image on the cold storage:

```bash
docker load -i <USB_path/cardano-node-image.tar>
```

Now use it for cardano-cli:

```bash
docker run --rm -i ststolz/cardano-node:latest cardano-cli [OPTION] ...
```

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

It is important, to put the path of the scripts into your PATH environment variable:

```
PATH=/path/to/script/executables:$PATH
```

and then execute the scripts from your "data" path. Also create a "./tmp" folder in "data".

To adapt it to other use cases, look at the commands `docker exec -w /data -i cardano cardano-cli` and `docker exec -w /data -i cardano cardano-node`. This is how you can call the executables from outside the container. 

## Security 

If you have security concerns refer to the [Dockerfile](https://github.com/ststolz/Cardano-Node-Docker/blob/main/Dockerfile) the image is built from. All software used was sourced from official Ubuntu Repositories or the original Software Repositories (haskell.org and input-output-hk). Your are free to build the image on your own. See instructions in the [docker-compose.yml](https://github.com/ststolz/Cardano-Node-Docker/blob/main/docker-compose.yml).

## MIT License

Copyright (c) 2020 Stefan Stolz

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
