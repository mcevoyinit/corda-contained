#!/bin/sh

set -eux

# Generate volumes for the images
rm -rf ./volumes
cp -r clean/volumes ./volumes

# Copy correct jars to image folders
cp ./jars/corda-finance-contracts-4.0.jar ./volumes/parties/PartyA/cordapps/
cp ./jars/corda-finance-workflows-4.0.jar ./volumes/parties/PartyA/cordapps/
cp ./jars/corda-finance-contracts-4.0.jar ./volumes/parties/PartyB/cordapps/
cp ./jars/corda-finance-workflows-4.0.jar ./volumes/parties/PartyB/cordapps/
cp ./jars/corda-finance-contracts-4.0.jar ./volumes/notary/cordapps/
cp ./jars/corda-finance-workflows-4.0.jar ./volumes/notary/cordapps/

cp ./jars/doorman-0.4.jar ./enm_doorman-image/doorman.jar
cp ./jars/doorman-0.4.jar ./enm_netmap-image/doorman.jar

cp ./jars/corda-4.0.jar ./enm_notary-image/corda.jar
cp ./jars/corda-4.0.jar ./corda_party-image/corda.jar

#cp ./jars/corda-firewall-4.0.jar ./corda_firewall-image/corda-firewall.jar
