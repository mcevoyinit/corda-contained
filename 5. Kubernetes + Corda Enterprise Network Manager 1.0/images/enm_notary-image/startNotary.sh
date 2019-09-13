#!/usr/bin/env bash

echoMessage () {
    local message=$1

    echo "====== $message ======"
}

checkStatus () {
	local status=$1
	if [ $status -eq 0 ]
		then
			echoMessage "Success"
		else
			echoMessage "The previous step failed"
			exit 1
	fi	
}

isRegistered () {
    if [ -f ./persistent/nodeInfo-* ]
    then
        return 1
    else
        return 0
    fi
}

waitTillIdentityServiceIsUpAndRunning () {
	let EXIT_CODE=255
	while [ ${EXIT_CODE} -gt 0 ]
	do
		sleep 2
		echoMessage "Trying to contact doorman..."
		curl -m5 -s http://enm-identity-service:10000 > /dev/null
		let EXIT_CODE=$?
	done
	
	echoMessage "Identity service is up and running"
}

submitNodeInfoFile () {
	nodeInfoFileName=`ls ./persistent/nodeInfo-*`
	echoMessage "File to submit is ${nodeInfoFileName}"
	lftp -c "open -u user,password enm-nfs-service; put ${nodeInfoFileName}"
	checkStatus $?
}

registerNotary () {
	java -jar corda-4.0.jar --initial-registration --network-root-truststore ./persistent/network-root-truststore.jks --network-root-truststore-password trustpass --config-file notary.conf
	checkStatus $?
}

startNotary () {
	java -jar corda-4.0.jar -f notary.conf
	checkStatus $?
}

isRegistered
registered=$?

if [ $registered -eq 1 ]
	then
		echoMessage "Starting the notary"
		startNotary
	else
	    echoMessage "Checking doorman's availability"
		waitTillIdentityServiceIsUpAndRunning
		
		echoMessage "Registering the notary first"
		registerNotary
		
		echoMessage "Submitting nodeInfo file to NFS"
		submitNodeInfoFile
		
		echoMessage "Now starting the notary"
		startNotary
fi

