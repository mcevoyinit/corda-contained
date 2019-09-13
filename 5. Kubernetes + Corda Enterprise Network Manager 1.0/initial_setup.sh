#!/bin/sh

set -eux

# Build volumes
./build_volumes.sh

# Generate PKI certs
./build_pki.sh

# Generate Docker images
./build_docker_images.sh

echo "You can now start the images using start.sh"