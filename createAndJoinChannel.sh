#!/bin/bash

echo "---------- Creating testchannel genesis block ----------"

export FABRIC_CFG_PATH=$PWD/
configtxgen -profile SampleNew -outputBlock testchannel.genesis_block.pb -channelID testchannel

echo "---------- Creating and joining orderer1 to the testchannel ----------"

export ORDERER_TLS_CA=$PWD/orderingservice/client/tls-ca-cert.pem
export ORDERER_ADMIN_CERT=$PWD/orderingservice/orderer1/adminclient/client-tls-cert.pem
export ORDERER_ADMIN_KEY=$PWD/orderingservice/orderer1/adminclient/client-tls-key.pem
export ORDERDER_ADMIN_ADDRESS=0.0.0.0:7051

osnadmin channel join --channelID testchannel  --config-block testchannel.genesis_block.pb -o $ORDERDER_ADMIN_ADDRESS --ca-file $ORDERER_TLS_CA --client-cert $ORDERER_ADMIN_CERT --client-key $ORDERER_ADMIN_KEY
sleep 3

echo "---------- Fetching the genesis block of testchannel and joining peer1.Org1.com ----------"

export CORE_PEER_LOCALMSPID=Org1
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=0.0.0.0:8054
export FABRIC_CFG_PATH=$PWD
export ORDERER_TLS_CA=$PWD/orderingservice/client/tls-ca-cert.pem
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/Org1/client/tls-ca-cert.pem
export CORE_PEER_MSPCONFIGPATH=$PWD/Org1/client/org-ca/orgadmin/msp/
export CORE_PEER_TLS_ENABLED=true
export ORDERER_ADDRESS=0.0.0.0:7050

cp $PWD/config.yaml $PWD/Org1/client/org-ca/orgadmin/msp/
peer channel fetch oldest -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA --tls -c testchannel $PWD/Org1/peer1/testchannel.genesis.block
peer channel join -b $PWD/Org1/peer1/testchannel.genesis.block

echo "---------- Fetching the genesis block of testchannel and joining peer1.Org2.com ----------"

export CORE_PEER_LOCALMSPID=Org2
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=0.0.0.0:9054
export FABRIC_CFG_PATH=$PWD
export ORDERER_TLS_CA=$PWD/orderingservice/client/tls-ca-cert.pem
export CORE_PEER_TLS_ROOTCERT_FILE=$PWD/Org2/client/tls-ca-cert.pem
export CORE_PEER_MSPCONFIGPATH=$PWD/Org2/client/org-ca/orgadmin/msp/
export CORE_PEER_TLS_ENABLED=true
export ORDERER_ADDRESS=0.0.0.0:7050

cp $PWD/config.yaml $PWD/Org2/client/org-ca/orgadmin/msp/
peer channel fetch oldest -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA --tls -c testchannel $PWD/Org2/peer1/testchannel.genesis.block
peer channel join -b $PWD/Org2/peer1/testchannel.genesis.block
