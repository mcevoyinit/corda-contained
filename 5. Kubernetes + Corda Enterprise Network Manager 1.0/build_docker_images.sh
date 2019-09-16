#!/bin/sh

set -eux
NO_CACHE=--no-cache
NO_CACHE=

cd enm_doorman-image
docker build -t enm_doorman . -f doorman-Dockerfile $NO_CACHE
cd ..

cd enm_netmap-image
docker build -t enm_netmap . -f netmap-Dockerfile $NO_CACHE
cd ..

cd enm_nfs-image
docker build -t enm_nfs . -f nfs-Dockerfile $NO_CACHE
cd ..

cd enm_notary-image
docker build -t enm_notary . -f notary-Dockerfile $NO_CACHE
cd ..

cd corda_party-image
docker build -t corda_party . -f party-Dockerfile $NO_CACHE
cd ..

docker images "enm_*"
