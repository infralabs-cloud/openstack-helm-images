#!/bin/bash
SCRIPT=`realpath $0`
SCRIPT_DIR=`dirname ${SCRIPT}`
## Only build from main folder
cd ${SCRIPT_DIR}/..

IMAGE="ceph-config-helper"
VERSION=${VERSION:-latest}
DISTRO=${DISTRO:-ubuntu}
DISTRO_VERSION=${DISTRO_VERSION:-jammy}
REGISTRY_URI=${REGISTRY_URI:-"openstackhelm/"}
EXTRA_TAG_INFO=${EXTRA_TAG_INFO:-""}

# CEPH-related variables
CEPH_RELEASE=${CEPH_RELEASE:-squid}
CEPH_RELEASE_TAG=${CEPH_RELEASE_TAG:-19.2.1-1~jammy}
CEPH_REPO=${CEPH_REPO:-"https://download.ceph.com/debian-quincy"}
CEPH_KEY=${CEPH_KEY:-"https://download.ceph.com/keys/release.asc"}

docker build --file=${IMAGE}/Dockerfile.${DISTRO} \
             --network=host \
             --build-arg="FROM=${DISTRO}:${DISTRO_VERSION}" \
             --build-arg="CEPH_RELEASE=${CEPH_RELEASE}" \
             --build-arg="CEPH_RELEASE_TAG=${CEPH_RELEASE_TAG}" \
             --build-arg="CEPH_REPO=${CEPH_REPO}" \
             --build-arg="CEPH_KEY=${CEPH_KEY}" \
             --tag=${REGISTRY_URI}${IMAGE}:${VERSION}-${DISTRO}_${DISTRO_VERSION}${EXTRA_TAG_INFO} \
             ${extra_build_args} ${IMAGE}

cd -
