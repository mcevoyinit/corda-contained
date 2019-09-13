# Docker + Corda

In this first example we will build and run a simple Docker image of a Corda node.

## Reviewing the contents of this repository.

This folder contains the following


* Dockerfile needed to assemble the image
* As the node runs within a container, several mount points are required:

          CorDapps - CorDapps must be mounted at location /opt/corda/cordapps
          Certificates - certificates must be mounted at location /opt/corda/certificates
          Config - the node config must be mounted at location /etc/corda/node.config
          Logging - all log files will be written to location /opt/corda/logs

* The official Corda 4 platform jar file
* A node configuration or `node.conf` file
* A entry point bash script to be executed when the container launches

## Usage  
Let us review the commands that are used to set up the Docker images and then run the container 

Build the Dockerfile into an executable image

          docker build -t corda_party . -f party-Dockerfile $NO_CACHE
          
List all images and run the image you have just created

          docker images 
          docker run corda_party
     
At this point we have successfully executed a flow between multiple Nodes on the newly created test network!  
