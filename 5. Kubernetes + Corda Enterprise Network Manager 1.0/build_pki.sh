#!/bin/sh

set -eux

# Clean any old certs
rm -f ./pki/*.jks

# Build PKI certs
cd pki
java -jar utilities.jar cert-hierarchy-generator --config-file pki-generation.conf
cd ..

cp pki/caKeyStore.jks volumes/doorman/
cp pki/certificateStore.jks volumes/doorman/

cp pki/caKeyStore.jks volumes/netmap/
cp pki/certificateStore.jks volumes/netmap/

cp pki/networkRootTrustStore.jks volumes/notary/
cp pki/networkRootTrustStore.jks volumes/notary/
cp pki/networkRootTrustStore.jks volumes/parties/PartyA/
cp pki/networkRootTrustStore.jks volumes/parties/PartyB/
