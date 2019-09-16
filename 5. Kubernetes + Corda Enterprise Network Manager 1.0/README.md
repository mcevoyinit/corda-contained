## TLDR;
1. Run the `inital_setup.sh` script followed by the `start.sh` script
2. Check the status of your pods via `kubectl get pods`
3. Open shell on one of the pods by `kubectl exec -it --pod name-- -- /bin/bash`
4. If it's a node pod ssh in by `ssh localhost -p 2223 -l testuser` (password in the node.confs)
5. In the shell, run `run networkMapSnapshot` as a sanity check
6. To pull everything down and recopy the volumes templates run `delete.sh` script


## PREREQUISITES 

1. Docker to build the necessary images
2. Kubernetes cluster to deploy the services on
3. ENM doorman jar for running doorman and netmap
4. ENM utilities jar for generating PKI files (unless you already have them or generate them otherwise)
5. Corda jar to run the notary or other Corda nodes


## SETUP
Execute initial_setup.sh which sets everything up.
Then run start.sh to spin up the Kubernetes cluster.
delete-all.sh will stop the cluster.

## BUILDING IMAGES (THE MANUAL WAY) 

1. enm_doorman

   a) drop the doorman.jar into the enm_doorman-image directory and cd in there
   b) docker build -t enm_doorman . -f doorman-Dockerfile

2. enm_netmap

   a) drop the doorman.jar into the enm_netmap-image directory and cd in there
   b) docker build -t enm_netmap . -f netmap-Dockerfile

3. enm_nfs

   a) cd into the enm_nfs-image directory
   b) docker build -t enm_nfs . -f nfs-Dockerfile

4. enm_notary

   a) drop the corda.jar into the enm_notary-image directory and cd in there
   b) docker build -t enm_notary . -f notary-Dockerfile

5. corda_party (optional, only if you want to deploy some nodes to, say, test the installation)

   a) drop the corda.jar into the corda_party-image directory and cd in there
   b) docker build -t corda_party . -f party-Dockerfile

Sanity check:

   a) running docker images enm_* should show this:

	REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
	enm_notary          latest              a05044bfc448        2 minutes ago       298MB
	enm_nfs             latest              61aebaa4c388        4 minutes ago       169MB
	enm_netmap          latest              5a4fffd24483        5 minutes ago       371MB
	enm_doorman         latest              30dc8d4ac832        7 minutes ago       369MB

   b) running docker images corda_* should show this:

	REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
	corda_party         latest              7ed7c71dff47        About a minute ago   298MB


## EDITING THE PERSISTENT VOLUMES YML FILES

1. Navigate to the kbs-enm-persistent-volumes directory and edit the yml files there to your liking. They represent the persistent volumes to be used by the various services. Keep the name and "purpose" unmodified. Be aware that on Windows the hostPath has to have the form of, e.g., "/C/dir"

2. If you are planning on deploying also some test Corda nodes then edit the persistent volume yml files also in kbs-nodes-persistent-volumes. Again, keep the name and the "purpose" unmodified.


## GENERATING THE PKI FILES 

1. Generate the PKI files as per here: http://docs.netman.r3.com/quick-start.html#generate-the-pki

## PREPARING THE PERSISTENT VOLUMES 

The persistent volumes act as the workspace of the services and nodes, they have to have some files in them before the services can start, such as the PKI files generated in the previous step

1. The doorman's workspace needs to contain

	a) caKeyStore.jks
	b) certificateStore.jks
	c) doorman.conf (you can use the one from config_examples directory)

2. The netmap's workspace needs to contain

	a) caKeyStore.jks
	b) certificateStore.jks
	c) network-map.conf (you can use the one from config_examples directory)
	d) network-parameters-template.conf (you can use the one from the config_examples directory)

3. The notary's workspace needs to contain

	a) networkRootTrustStore.jks
	b) node.conf (you can use the one from the config_examples directory, called notary-node.conf)

4. The party's (ordinaty node's) workspace needs to contain

	a) networkRootTrustStore.jks
	b) node.conf (you can use the one from the config_examples directory, called ordinary-node.conf)
	c) optionally cordapps directory with cordapps in it

	Note that each party has to have its own workspace (i.e. persistent volume) and its unique node.conf in there, use the ordinary-node.conf as a base.

## DEPLOYING ENM AND NOTARY ON KUBERNETES 

At this stage everything is ready to deploy the ENM and notary

	a) kubectl apply -f kbs-enm-persistent-volumes <-- deploys the persistent volumes
	b) kubectl apply -f kbs-enm                    <-- deploys the persistent volume claims, pods and services

Sanity check:

	a) running  should show this:

		enm-doorman-deployment-8488676979-jkfpb   1/1       Running   0          1m
		enm-netmap-deployment-c44d6cd97-jrnnk     1/1       Running   0          1m
		enm-nfs-deployment-7d6b7578c9-8jmkj       1/1       Running   0          1m
		enm-notary-deployment-f64578d4d-pnxxl     1/1       Running   0          1m

	b) give it a few moments (even minutes)
	c) the notary container may restart a couple of times until the network map becomes available
	d) eventually the nfs persistent volume should contain a "nodeInfo" file and all services are up and running. You can check the logs

If you wish you can also deploy some test nodes at the same time. 

	   a) kubectl apply -f kbs-nodes-persistent-volumes <-- deploys the persistent volumes
        b) kubectl apply -f kbs-nodes                    <-- deploys the persistent volume claims, pods and services

Sanity check:

	a) running kubectl get pods should show these extra pods:

		corda-partya-deployment-67ccfc8c7c-9lfhs   1/1       Running   0          35s
		corda-partyb-deployment-5c57b65748-dqh86   1/1       Running   0          35s

	b) open shell on one of the party pods by kubectl exec -it --pod name-- -- /bin/bash
           ssh into the node by ssh localhost -p 2223 -l testuser
           password is example-password (as per node.conf)
           in the shell, run "run networkMapSnapshot"
           you should see the notary and all nodes in the snapshot

        




