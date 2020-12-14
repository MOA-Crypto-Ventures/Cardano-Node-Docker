for i in $*;
do
    params=" $params $i"
done

echo "Reconfigure config.json"
sed -i 's/12788/'${EKG_PORT}'/' ${CNODE_HOME}/files/config.json
sed -i 's/12798/'${PROM_PORT}'/' ${CNODE_HOME}/files/config.json

# cardano-node run    --config ${CNODE_HOME}/files/config.json \
#                     --topology ${CNODE_HOME}/files/topology.json \
#                     --database-path ${CNODE_HOME}/db \
#                     --socket-path ${CNODE_HOME}/sockets/node0.socket \
#                     --host-addr 0.0.0.0 \
#                     --port ${CNODE_PORT} $params

bash -x cnode.sh                 