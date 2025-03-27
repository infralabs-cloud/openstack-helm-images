#!/bin/bash
SCRIPT=`realpath $0`
SCRIPT_DIR=`dirname ${SCRIPT}`
## Only build from main folder
cd ${SCRIPT_DIR}/..

IMAGE="libvirt"
FROM=ubuntu:jammy
RELEASE=dalmatian
VERSION=${VERSION:-latest}
DISTRO=${DISTRO:-ubuntu}
REGISTRY_URI=${REGISTRY_URI:-"openstackhelm/"}

# Remove any existing builder
docker buildx rm multi-arch-builder || true

# Create and use new builder
docker buildx create --driver docker-container --use

# Build for multiple architectures
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -f ${IMAGE}/Dockerfile.${DISTRO} \
    --network=host \
    -t ${REGISTRY_URI}${IMAGE}:${VERSION}-${DISTRO}_${DISTRO_VERSION}\
    ${extra_build_args} \
    ${IMAGE}

cd -