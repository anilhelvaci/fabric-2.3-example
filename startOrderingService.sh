#!/bin/bash

docker-compose -p fabric-2.3 up -d tlsca.orderingservice.com
sleep 5
mkdir $PWD/orderingservice/client
mkdir $PWD/orderingservice/msp
cp $PWD/orderingservice/server/tls-ca/crypto/ca-cert.pem $PWD/orderingservice/client/tls-ca-cert.pem

export FABRIC_CA_CLIENT_HOME=$PWD/orderingservice/client
export FABRIC_CA_CLIENT_TLS_CERTFILES=$PWD/orderingservice/client/tls-ca-cert.pem

set -x
fabric-ca-client enroll -u https://tls-ca-admin:tls-ca-adminpw@0.0.0.0:7052 -M tls-ca/admin/msp --csr.hosts '0.0.0.0,*.orderingservice.com' --enrollment.profile tls
{ set +x; } 2>/dev/null

set -x
fabric-ca-client register -d --id.name org-ca-admin --id.secret org-ca-adminpw --id.type admin -u https://0.0.0.0:7052 -M tls-ca/admin/msp
{ set +x; } 2>/dev/null

set -x
fabric-ca-client register -d --id.name orderer1 --id.secret orderer1pw --id.type orderer -u https://0.0.0.0:7052 -M tls-ca/admin/msp
{ set +x; } 2>/dev/null

set -x
fabric-ca-client register -d --id.name osn-admin --id.secret osn-adminpw --id.type client -u https://0.0.0.0:7052 -M tls-ca/admin/msp
{ set +x; } 2>/dev/null

set -x
fabric-ca-client enroll -u https://org-ca-admin:org-ca-adminpw@0.0.0.0:7052 -M tls-ca/orgadmin/msp --csr.hosts '0.0.0.0,*.orderingservice.com' --enrollment.profile tls
{ set +x; } 2>/dev/null

set -x
fabric-ca-client enroll -u https://orderer1:orderer1pw@0.0.0.0:7052 -M tls-ca/orderer1/msp --csr.hosts '0.0.0.0,*.orderingservice.com' --enrollment.profile tls
{ set +x; } 2>/dev/null

set -x
fabric-ca-client enroll -u https://osn-admin:osn-adminpw@0.0.0.0:7052 -M tls-ca/osnadmin/msp --csr.hosts '0.0.0.0,*.orderingservice.com' --enrollment.profile tls
{ set +x; } 2>/dev/null

mkdir -p $PWD/orderingservice/server/org-ca/tls
mv $PWD/orderingservice/client/tls-ca/orgadmin/msp/keystore/*_sk $PWD/orderingservice/client/tls-ca/orgadmin/msp/keystore/key.pem
cp $PWD/orderingservice/client/tls-ca/orgadmin/msp/signcerts/cert.pem $PWD/orderingservice/server/org-ca/tls/
cp $PWD/orderingservice/client/tls-ca/orgadmin/msp/keystore/key.pem $PWD/orderingservice/server/org-ca/tls/
mv $PWD/orderingservice/client/tls-ca/osnadmin/msp/keystore/*_sk $PWD/orderingservice/client/tls-ca/osnadmin/msp/keystore/client-tls-key.pem
mv $PWD/orderingservice/client/tls-ca/osnadmin/msp/signcerts/cert.pem $PWD/orderingservice/client/tls-ca/osnadmin/msp/signcerts/client-tls-cert.pem

docker-compose -p fabric-2.3 up -d orgca.orderingservice.com
sleep 5

set -x
fabric-ca-client enroll -u https://org-ca-admin:org-ca-adminpw@0.0.0.0:7053 -M org-ca/admin/msp --csr.hosts '0.0.0.0,*.orderingservice.com'
{ set +x; } 2>/dev/null

set -x
fabric-ca-client register -d --id.name orderer1 --id.secret orderer1pw --id.type orderer -u https://0.0.0.0:7053 -M org-ca/admin/msp
{ set +x; } 2>/dev/null

set -x
fabric-ca-client register -d --id.name org-admin --id.secret org-adminpw --id.type admin -u https://0.0.0.0:7053 -M org-ca/admin/msp
{ set +x; } 2>/dev/null

set -x
fabric-ca-client enroll -u https://org-admin:org-adminpw@0.0.0.0:7053 -M org-ca/orgadmin/msp --csr.hosts '0.0.0.0,*.orderingservice.com'
{ set +x; } 2>/dev/null

set -x
fabric-ca-client enroll -u https://orderer1:orderer1pw@0.0.0.0:7053 -M org-ca/orderer1/msp --csr.hosts '0.0.0.0,*.orderingservice.com'
{ set +x; } 2>/dev/null


mkdir $PWD/orderingservice/msp/tlscacerts
mkdir $PWD/orderingservice/msp/cacerts
cp $PWD/orderingservice/client/tls-ca-cert.pem $PWD/orderingservice/msp/tlscacerts/
cp $PWD/orderingservice/client/org-ca/orgadmin/msp/cacerts/0-0-0-0-7053.pem $PWD/orderingservice/msp/cacerts/
cp $PWD/config.yaml $PWD/orderingservice/msp

mv $PWD/orderingservice/client/tls-ca/orderer1/msp/keystore/*_sk $PWD/orderingservice/client/tls-ca/orderer1/msp/keystore/key.pem
mv $PWD/orderingservice/client/org-ca/orderer1/msp/keystore/*_sk $PWD/orderingservice/client/org-ca/orderer1/msp/keystore/key.pem

mkdir -p $PWD/orderingservice/orderer1/tls
mkdir $PWD/orderingservice/orderer1/adminclient
mkdir $PWD/orderingservice/orderer1/localMsp
cp $PWD/orderingservice/client/tls-ca/orderer1/msp/signcerts/cert.pem $PWD/orderingservice/orderer1/tls/
cp $PWD/orderingservice/client/tls-ca/orderer1/msp/keystore/key.pem $PWD/orderingservice/orderer1/tls/
cp $PWD/orderingservice/client/tls-ca-cert.pem $PWD/orderingservice/orderer1/tls/tls-ca-cert.pem
cp $PWD/orderingservice/client/tls-ca/osnadmin/msp/signcerts/client-tls-cert.pem $PWD/orderingservice/orderer1/adminclient/
cp $PWD/orderingservice/client/tls-ca/osnadmin/msp/keystore/client-tls-key.pem $PWD/orderingservice/orderer1/adminclient/
cp -r $PWD/orderingservice/client/org-ca/orderer1/msp/* $PWD/orderingservice/orderer1/localMsp/
cp $PWD/config.yaml $PWD/orderingservice/orderer1/localMsp
cp $PWD/orderer.yaml $PWD/orderingservice/orderer1/

docker-compose -p fabric-2.3 up -d orderer1.orderingservice.com

