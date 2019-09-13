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

doNetworkParametersExist () {
    if [ -f ./persistent/networkParametersGenerated ]
    then
        return 1
    else
        return 0
    fi
}

waitTillNotaryNodeInfoFilesAreAvailable () {
	let NUMBER_OF_FILES=0
	while [ ! ${NUMBER_OF_FILES} -gt 0 ]
	do
		sleep 2
		echoMessage "Trying to fetch some notary node info files"
		downloadNotaryNodeInfoFiles
		let NUMBER_OF_FILES=`ls nodeInfo-* | wc -l`
	done
	
	echoMessage "Notary node info files are available"
}

downloadNotaryNodeInfoFiles () {
	lftp -c "open -u user,password enm-nfs-service; mget nodeInfo-*"
}

createNetworkParametersFile () {
    ENTRIES=""
	FILES=./nodeInfo-*
	for f in $FILES
	do
	  echo "Processing $f file..."
	  entry="
		  {
			notaryNodeInfoFile: `basename $f`
			validating: false
		  }	  
	  "
	  ENTRIES="$ENTRIES
	           $entry
		      "	
	done
	
	dos2unix ./persistent/network-parameters-template.conf ./persistent/network-parameters-template.conf
	awk -v r="$ENTRIES" '{gsub(/#Notary_Information#/,r)}1' ./persistent/network-parameters-template.conf > ./persistent/network-parameters.conf
	checkStatus $?
}

setInitialNetworkParameters () {
	java -Dlog4j.configurationFile=file:./log4j2.xml -jar networkmap.jar --config-file ./persistent/network-map.conf --set-network-parameters ./persistent/network-parameters.conf --network-truststore ./persistent/certificateStore.jks --truststore-password example-password --root-alias cordarootca --ignore-migration
	checkStatus $?
	touch ./persistent/networkParametersGenerated
	checkStatus $?
}

startTheNetmap () {
    java -jar networkmap.jar -f networkmap.conf --ignore-migration
	checkStatus $?
}

doNetworkParametersExist
networkParametersExist=$?

if [ $networkParametersExist -eq 1 ]
	then
		echoMessage "Starting the netmap"
		startTheNetmap
	else
	    echoMessage "Download notary node info files"
		waitTillNotaryNodeInfoFilesAreAvailable
		
		echoMessage "Creating network parameters file"
		createNetworkParametersFile
		
		echoMessage "Setting initial network parameters"
		setInitialNetworkParameters
		
		echoMessage "Starting the netmap"
		startTheNetmap
		
fi

