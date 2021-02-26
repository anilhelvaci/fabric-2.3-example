# fabric-2.3-example

This is an example project regarding usage of **osnadmin** command which enables users to create new channels without a consortium and disables the system channel.
Also in this network every organization has one TLS CA Server and one Ca Server which is the suggested production network design 

## Prerequisites

In order to make this demo work you should have installed the following programs on your machine;

* OS: Linux (WSL or VM will do too)
* [Hyperledger Fabric Release 2.3](https://github.com/hyperledger/fabric/releases/tag/v2.3.1)
* [Hyperledger Fabric-Ca Release 1.4](https://github.com/hyperledger/fabric-ca/releases/tag/v1.4.9)
* Docker 
* Docker Compose

> For the correct version of docker and docker-compose check out [Hyperledger Fabric Prerequisites](https://hyperledger-fabric.readthedocs.io/en/release-2.3/prereqs.html)

## Running the demo
Since we will run the scripts with ``sudo`` you shoıld add the binaries you extracted from fabric and fabric-ca to the PATH which sudo will be able to detect. One simple solution could be copying the binaries of fabric and fabric-ca to /bin folder of your computer.

1. Clone this repo using `git clone https://github.com/anilhelvaci/fabric-2.3-example.git` then `cd` into it

3. At first you should bring start the ordering service;<br/> `sudo ./startOrderingService.sh`

5. Now bring up your peer organizations using;<br/>`sudo ./startOrg1.sh` and `sudo ./startOrg2.sh`

7. Then it is time to create a new channel and join our peers to it. To do this run;<br/> `sudo ./createAndJoinChannel`


### Using CLI
Once everything is up and running you can `package`, `install`, `approve`, `commit`, `invoke`, `query` your chaincode and many more operations. For further information check the offical documentation. In context of this demo we will use the packaged chaincode in this reposiory to demonstrate the usages stated above.

#### Operating on Both CLIs
In this network we have two clis and some chaincode operations have to be run on both of them. We will do them first. I am choosing the cli of Org1. Every operation that is done in this section must be applied in the other organization's cli too.
* Open cli terminal<br/>`docker exec -it cli.peer1.Org1.com bash`

* Install the chaincode to peer<br/>`peer lifecycle chaincode install javascript@0.0.1.tar.gz`

* Check if installation succesful <br/>`peer lifecycle chaincode queryinstalled`

* You should see something like this<br/>```Installed chaincodes on peer:Package ID: javascript_0.0.1:42ad3b2bf2c78d1b5330245a6e1f104b6735f81dba326239d52d13008631ff90, Label: javascript_0.0.1```

* Copy the *Package ID* to the environment varianle *CC_PACKAGE_ID*<br/>`export CC_PACKAGE_ID=javascript_0.0.1:42ad3b2bf2c78d1b5330245a6e1f104b6735f81dba326239d52d13008631ff90`

* Now approve the installed chaincode<br/>`peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS --channelID testchannel --name javascript --version 0.0.1 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_TLS_CA`<br/>_The environment variables other than the CC_PACKAGE_ID are set inside the cli container, you don't have to do anything_

* Now check if it is ready to commit or not<br/>`peer lifecycle chaincode checkcommitreadiness --channelID testchannel --name javascript --version 0.0.1 --sequence 1 --tls --cafile $ORDERER_TLS_CA --output json`

* Every organization specified in the endorsment policy should approve the chaincode so in our case we go with the defaults whic the majority and the majority of two is two we should see something like this after we run the above command<br/>`{"approvals": {"Org1": true,"Org2": true}}`

**_DO NOT FORGET TO THE ABOVE STEPS FOR THE OTHER ORGANIZATION CLI_**

#### Operating on one CLI
After we complete above steps we can now operate on one cli
* Time to commit the chaincode to the ledger<br/>`peer lifecycle chaincode commit -o $ORDERER_ADDRESS --channelID testchannel --name javascript --version 0.0.1 --sequence 1 --tls --cafile $ORDERER_TLS_CA --peerAddresses peer1.Org1.com:8054 --tlsRootCertFiles ./Org1/peer1/tls/tls-ca-cert.pem --peerAddresses peer1.Org2.com:9054 --tlsRootCertFiles ./Org2/peer1/tls/tls-ca-cert.pem`

* Now we can finally work with our chaincode.For example<br/>`peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_TLS_CA -C testchannel -n javascript --peerAddresses peer1.dogus.com:8054 --tlsRootCertFiles ./dogus/peer1/tls/tls-ca-cert.pem --peerAddresses peer1.unsped.com:9054 --tlsRootCertFiles ./unsped/peer1/tls/tls-ca-cert.pem -c '{"function":"myAssetExists","Args":["1"]}'`

* Should output something like this;<br/>`2021-02-25 10:45:49.791 UTC [chaincodeCmd] chaincodeInvokeOrQuery -> INFO 001 Chaincode invoke successful. result: status:200 payload:"false"`

* To write data to the ledger;<br/>`peer chaincode invoke -o $ORDERER_ADDRESS --tls --cafile $ORDERER_TLS_CA -C testchannel -n javascript --peerAddresses peer1.dogus.com:8054 --tlsRootCertFiles ./dogus/peer1/tls/tls-ca-cert.pem --peerAddresses peer1.unsped.com:9054 --tlsRootCertFiles ./unsped/peer1/tls/tls-ca-cert.pem -c '{"function":"createMyAsset","Args":["1", "hello world"]}'`

* To query it;<br/>`peer chaincode query -C testchannel -n javascript -c '{"Args":["readMyAsset", "1"]}'`
