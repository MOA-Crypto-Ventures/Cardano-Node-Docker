# Cardano-Node-Docker

[cardano-node](https://github.com/input-output-hk/cardano-node) Docker image with configured [CNTools](https://cardano-community.github.io/guild-operators/#/Scripts/cntools) to be flexible, fast and safe in deployment.

## News 2020-12-02

1. [CNTools](https://cardano-community.github.io/guild-operators/#/Scripts/cntools) are implemented ready to use
2. To make it more simple, I **edited the ENTRYPOINT**. So keep care to **change your docker-compose.yml and your scripts** with newly pulled images. Look at the examples below. 

## Introduction

This "Dockerfile" compiles cardano-node, cardano-cli and installs / configures CNTools. With some Docker skills you can run a Cardano node and do transactions or similar with CNTools with ease. To run a stake pool or relay node you will additionally need **Cardano Stake Pool Operator** skills as well as Bash and Docker skills. The "docker-compose.yml" file example contains all instructions to build the image and run the container. It is suited for a relay node. Feel free to copy it and adopt the run command for the block producing node. 

## How to start a node

### Simple start without persistence 

To start the node for usage of cardano-cli or CNTools use a command like this:

```bash
docker run --rm -ti --name cardano-node ststolz/cardano-node:latest
```

When syncing is done, you can use cardano-cli or CNTools:

```bash
docker exec -ti cardano-node cardano-cli [ ARGS ]
docker exec -ti cardano-node cntools.sh
```

### Start node with persistence

Following "docker-compose.yml" example uses volumes for persistence of the node: 

```yml
version: '2'

services:

    cardano-node:
        image: ststolz/cardano-node:1.25.1
        container_name: stolz-cardano-relay
        network_mode: host
        volumes:
            # - ./files:/opt/cardano/cnode/files
            - ./db:/opt/cardano/cnode/db
            - ./sockets:/opt/cardano/cnode/sockets
            - ./priv:/opt/cardano/cnode/priv
            - ./tmp:/tmp
        environment:
            - CNODE_PORT=6000
            - EKG_HOST=127.0.0.1
            - EKG_PORT=12788
            - PROM_PORT=12798
            # - POOL_NAME=POOL
            # (Optional) Must resolve to the IP you are requesting from
            # - CNODE_HOSTNAME="CHANGE ME"
            # Additional custom peers to (IP:port[:valency]) to add to your target topology.json, eg: "10.0.0.1:3001|10.0.0.2:3002|relays.mydomain.com:3003:3"
            # - CUSTOM_PEERS=""
        build:
            dockerfile: Dockerfile
            context: ./
        # command only needed if not using cntools folder structure
        # if using cntools folder structure you only have to set env POOL_NAME
        # command: [ 
        #            "--port", "7030",
        #            "--host-addr <PUBLIC IP>",
        #            "--shelley-kes-key kes.skey",
        #            "--shelley-vrf-key vrf.skey",
        #            "--shelley-operational-certificate node.cert" 
        # ]
```

For a testnet example look at [docker-compose-testnet.yml](https://github.com/ststolz/Cardano-Node-Docker/blob/main/docker-compose-testnet.yml) in the GitHub Repository. 

1. Create a "docker-compose.yml" file like the example
2. Change into directory containing docker-compose.yml and execute `docker-compose up`
3. Congrats! Relay Node running and CNTools are ready to use!

## How to setup a Cardano Relay Node

1. Comment out the volumes entry for "files" folder in docker-compose.yml example
2. Download Topology/config files from [hydra.iohk.io](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html) and put them into the "files" folder. Keep care that names are: "config.json" and "mainnet-topology.json". Alternatively you can start a node like in first example and copy the folder "/files" out of the container into local file system with `docker cp` command.
3. Edit Topology and after `docker-compose up` your relay node is running

## How to setup a Staking Pool with cntools

1. Start the node with volume priv mounted (look at docker-compose.yml example) for persistence. To edit relay pools you also have to mount files (look at "How to setup a Cardano Relay Node" fot init)
2. Switch to container `docker exec -ti container-name bash`
3. Start cntools.sh and create the pool
4. Set the env for pool name and restart container

## Usage Examples

### execute cardano-cli

On running container:

```bash
docker exec -i <container_id> cardano-cli [OPTION] ...
```

Run a container only for cardano-cli:

```bash
docker run --rm -i --entrypoint cardano-cli ststolz/cardano-node:latest [OPTION] ...
```

### Use implemented CNTools

1. start your node
2. Execute: `docker exec -ti <container_id> cntools.sh`

### Use implemented `topologyUpdater.sh`

Get the name of the running container and then all you have to do, is to add following cron job. 

```crontab
30 */1 * * * docker exec ${container_name} topologyUpdater.sh
```

### How to use CNTools as cold storage

Transfer your image to the cold storage by exporting it to a USB drive:

```bash
docker save -o <USB_path/cardano-node-image.tar> ststolz/cardano-node:latest
```

Restore the image on the cold storage:

```bash
docker load -i <USB_path/cardano-node-image.tar>
```

You can use [cntools offline](https://cardano-community.github.io/guild-operators/#/Scripts/cntools-common?id=offline-workflow) with following command. Replace 74 by shelley epoch transition and replace ${PWD} by absolute path if you are using MS Windows.

```bash
docker run --rm -it -v ${PWD}/priv:/opt/cardano/cnode/priv -v ${PWD}/tmp:/tmp  ststolz/cardano-node:latest-testnet bash -c 'echo 74 > "/opt/cardano/cnode/guild-db/shelley_trans_epoch" && cntools.sh -o'
```

## Security 

If you have security concerns, refer to the [Dockerfile](https://github.com/ststolz/Cardano-Node-Docker/blob/main/Dockerfile) the image is built from. All software used was sourced from official Ubuntu Repositories or the original Software Repositories (haskell.org and input-output-hk). You are free to use my Dockerfile and build the image on your own. See instructions in the [docker-compose.yml](https://github.com/ststolz/Cardano-Node-Docker/blob/main/docker-compose.yml).

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
