#!/bin/bash
SCRIPT=`realpath $0`
SCRIPT_DIR=`dirname ${SCRIPT}`
cd ${SCRIPT_DIR}

IMAGE="skyline"
FROM=ubuntu:jammy
RELEASE=dalmatian
VERSION=${VERSION:-latest}
DISTRO=${DISTRO:-ubuntu}
DISTRO_VERSION=${DISTRO_VERSION:-jammy}
REGISTRY_URI=${REGISTRY_URI:-"sainusahib"}

# Check and setup builder
TAG_INFO=${1:-"latest"}
DOCKER_USER=${2:-""}
DOCKER_TOKEN=${3:-""}
GHCR_USER=${4:-""}
GHCR_TOKEN=${5:-""}


if ! docker buildx ls | grep -q multi-arch-builder; then
    docker buildx create --driver docker-container --name multi-arch-builder --use
else
    docker buildx use multi-arch-builder
fi
docker login docker.io -u $DOCKER_USER -p $DOCKER_TOKEN
docker login ghcr.io -u $GHCR_USER -p $GHCR_TOKEN


# Clean old clones if exist
rm -rf skyline-apiserver

# Clone repositories
git clone https://github.com/openstack/skyline-apiserver.git
cd skyline-apiserver

# Download prebuilt skyline-console tarball
mkdir -p skyline_console
wget -O skyline_console/skyline_console.tar.gz \
    https://tarballs.opendev.org/openstack/skyline-console/skyline-console-2.0.0.tar.gz

# Build for multiple architectures
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -f container/Dockerfile \
    --network=host \
    --push \
             --tag=${REGISTRY_URI}/${IMAGE}:${VERSION}-${DISTRO}_${DISTRO_VERSION}${EXTRA_TAG_INFO} \
             --tag=docker.io/${REGISTRY_URI}/${IMAGE}:${TAG_INFO}-${DISTRO}_${DISTRO_VERSION}${EXTRA_TAG_INFO} \
             --tag=ghcr.io/${GHCR_USER}/${IMAGE}:${TAG_INFO}-${DISTRO}_${DISTRO_VERSION}${EXTRA_TAG_INFO} \
    .

cd -