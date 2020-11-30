# Cardano-Node-Docker

Cardano node Docker version to be flexible, fast and safe in deployment.

## News

To be more flexible, I **removed the entrypoint**. So keep care to **change your docker-compose.yml and your scripts** with newly pulled images. See the examples below. 

## Introduction

This "Dockerfile" compiles cardano-node and cardano-cli. You will need **Cardano Stake Pool Operator** skills as well as basic Bash and Docker skills. The "docker-compose.yml" file contains all instructions to build the image and run the container. It is suited for a relay node. Feel free to copy it and adopt the run command for the block producing node. 

## How to start a node

Create a "docker-compose.yml" like the following:

```yml
version: '2'

services:

    cardano-node:
        image: ststolz/cardano-node:latest
        container_name: stolz-cardano-relay
        network_mode: host
        volumes:
            #- ./files:/opt/cardano/cnode/files
            - ./db:/opt/cardano/cnode/db
            - ./sockets:/opt/cardano/cnode/sockets
            - ./priv:/opt/cardano/cnode/priv
            - ./tmp:/tmp
        build:
            dockerfile: Dockerfile
            context: ./
        command: ["cardano-node", "run", 
                    "--config", "/opt/cardano/cnode/files/config.json", 
                    "--topology", "/opt/cardano/cnode/files/mainnet-topology.json", 
                    "--database-path", "/opt/cardano/cnode/db", 
                    "--socket-path", "/opt/cardano/cnode/sockets/node0.socket",
                    "--port", "7030"
                    ]
```

Look into GitHub Repository for docker-compose.yml testnet example. 

1. Change into directory containing docker-compose.yml and execute `docker-compose up`

Congrats! Relay Node running and cntools are ready to use!

## How to setup a Cardano Relay Node with docker-compose.yml

1. Comment out the volumes entry for "files" in docker-compose.yml example
2. Download Topology/config files from [hydra.iohk.io](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html) and put them into the "files" folder. Alternatively you can start a node like in first example and copy the folder "/files" out of the container into local file system with `docker cp` command (may not be up to date!).
3. Edit Topology and after `docker-compose up` your relay node is running

## Usage Examples

### Use implemented cntools

1. start your node
2. Execute: `docker exec -ti <container_id> cntools.sh`

### How to use with cntool as cold storage

Transfer your image to the cold storage by exporting it to an USB drive:

```bash
docker save -o <USB_path/cardano-node-image.tar> ststolz/cardano-node:latest
```

Restore the image on the cold storage:

```bash
docker load -i <USB_path/cardano-node-image.tar>
```

You can use now cardano-cli with following command:

```bash
docker run --rm -i ststolz/cardano-node:latest cardano-cli [OPTION] ...
```

You can use [cntools offline](https://cardano-community.github.io/guild-operators/#/Scripts/cntools-common?id=offline-workflow) with following command. Replace 74 by shelley epoch transition and replace ${PWD} by absolute path if you are using MS Windows.

```bash
docker run --rm -it -v ${PWD}/priv:/opt/cardano/cnode/priv -v ${PWD}/tmp:/tmp  ststolz/cardano-node:latest-testnet bash -c 'echo 74 > "/opt/cardano/cnode/guild-db/shelley_trans_epoch" && cntools.sh -o'
```

## Security 

If you have security concerns refer to the [Dockerfile](https://github.com/ststolz/Cardano-Node-Docker/blob/main/Dockerfile) the image is built from. All software used was sourced from official Ubuntu Repositories or the original Software Repositories (haskell.org and input-output-hk). Your are free to use my Dockerfile and build the image on your own. See instructions in the [docker-compose.yml](https://github.com/ststolz/Cardano-Node-Docker/blob/main/docker-compose.yml).

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
