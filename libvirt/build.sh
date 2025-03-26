#!/bin/bash
SCRIPT=`realpath $0`
SCRIPT_DIR=`dirname ${SCRIPT}`
## Only build from main folder
cd ${SCRIPT_DIR}/..

IMAGE="libvirt"
FROM=ubuntu:jammy
RELEASE=dalmatian
VERSION=${VERSION:-latest}
DISTRO=${DISTRO:-ubuntu_jammy}
REGISTRY_URI=${REGISTRY_URI:-"openstackhelm/"}
EXTRA_TAG_INFO=${EXTRA_TAG_INFO:-"-${LIBVIRT_VERSION}"}
docker build -f ${IMAGE}/Dockerfile.ubuntu --build-arg FROM=${DISTRO/_/:} --build-arg zed --network=host -t ${REGISTRY_URI}${IMAGE}:${VERSION}-${DISTRO}${EXTRA_TAG_INFO} ${extra_build_args} ${IMAGE}

cd -
