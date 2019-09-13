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

waitTillDoormanIsUpAndRunning () {
	let EXIT_CODE=255
	while [ ${EXIT_CODE} -gt 0 ]
	do
		sleep 2
		echoMessage "Trying to contact doorman..."
		curl -m5 -s http://enm-doorman-service:10000 > /dev/null
		let EXIT_CODE=$?
	done
	
	echoMessage "Doorman is up and running"
}

registerParty () {
    java -jar corda.jar --base-directory ./persistent --initial-registration --network-root-truststore-password example-password --network-root-truststore ./persistent/networkRootTrustStore.jks
	checkStatus $?
}

startParty () {
	java -jar corda.jar --base-directory ./persistent
	checkStatus $?
}

isRegistered
registered=$?

if [ $registered -eq 1 ]
	then
		echoMessage "Starting the party"
		startParty
	else
	    echoMessage "Checking doorman's availability"
		waitTillDoormanIsUpAndRunning
		
		echoMessage "Registering the party"
		registerParty
		
		echoMessage "Now starting the party"
		startParty
fi

