#!/bin/bash
SCRIPT=`realpath $0`
SCRIPT_DIR=`dirname ${SCRIPT}`
## Only build from main folder
cd ${SCRIPT_DIR}/..

IMAGE="kubernetes-entrypoint"
VERSION=${VERSION:-latest}
DISTRO=${DISTRO:-ubuntu}
DISTRO_VERSION=${DISTRO_VERSION:-noble}

REGISTRY_URI=${REGISTRY_URI:-"sainusahib"}
EXTRA_TAG_INFO=${EXTRA_TAG_INFO:-""}

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

git clone --depth=1 https://github.com/airshipit/kubernetes-entrypoint.git src
docker buildx build \
            --file=${IMAGE}/Dockerfile.${DISTRO} \
            --platform linux/amd64,linux/arm64 \
             --network=host \
             --push \
             --tag=${REGISTRY_URI}/${IMAGE}:${VERSION}-${DISTRO}_${DISTRO_VERSION}${EXTRA_TAG_INFO} \
             --tag=docker.io/${REGISTRY_URI}/${IMAGE}:${TAG_INFO}-${DISTRO}_${DISTRO_VERSION}${EXTRA_TAG_INFO} \
             --tag=ghcr.io/${GHCR_USER}/${IMAGE}:${TAG_INFO}-${DISTRO}_${DISTRO_VERSION}${EXTRA_TAG_INFO} \
             ${extra_build_args} src

cd -

