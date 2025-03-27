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
REGISTRY_URI=${REGISTRY_URI:-"openstackhelm/"}


# Check and setup builder
if ! docker buildx ls | grep -q multi-arch-builder; then
    docker buildx create --driver docker-container --name multi-arch-builder --use
else
    docker buildx use multi-arch-builder
fi

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
    --cache-from type=registry,ref=docker.io/${{ secrets.DOCKER_REGISTRY }}/${SERVICE}:cache \
    --cache-to type=registry,ref=docker.io/${{ secrets.DOCKER_REGISTRY }}/${SERVICE}:cache,mode=max \
    --tag docker.io/${{ secrets.DOCKER_REGISTRY }}/${SERVICE}:${{ github.event.inputs.version }}-ubuntu_jammy \
    --tag ghcr.io/${{ secrets.GHCR_REGISTRY }}/${SERVICE}:${{ github.event.inputs.version }}-ubuntu_jammy \
    .

cd -