for i in $*;
do
    params=" $params $i"
done

cardano-node run    --config /opt/cardano/cnode/files/config.json \
                    --topology /opt/cardano/cnode/files/topology.json \
                    --database-path /opt/cardano/cnode/db \
                    --socket-path /opt/cardano/cnode/sockets/node0.socket $params
                    