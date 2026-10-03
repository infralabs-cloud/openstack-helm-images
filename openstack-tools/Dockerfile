# syntax=docker/dockerfile:1
# OpenStack and Ceph command line tools in one image: every OpenStack client
# at the versions pinned by the release's upper-constraints, plus the Ceph
# client tools from the base image's Ceph repository.
ARG BASE_VENV_BUILDER=quay.io/airshipit/venv_builder:2025.2-ubuntu_noble
ARG BASE_RUNTIME=quay.io/airshipit/base:2025.2-ubuntu_noble
FROM ${BASE_VENV_BUILDER} AS build

ENV PATH=/var/lib/openstack/bin:$PATH

ARG OPENSTACKCLIENT_REPO=https://opendev.org/openstack/python-openstackclient
ARG OPENSTACKCLIENT_REF=stable/2026.1
ARG PROFILES=""

# Reuse the openstack-client profile for system and python packages
COPY bindep.txt pydep.txt /opt/
RUN mkdir -p /etc/image_info && \
    uvx bindep -f /opt/bindep.txt -b -l newline openstack-client ${PROFILES} > /etc/image_info/bindep_runtime.txt && \
    uvx bindep -f /opt/bindep.txt -b -l newline openstack-client build ${PROFILES} > /etc/image_info/bindep_build.txt && \
    uvx bindep -f /opt/pydep.txt -b -l newline openstack-client ${PROFILES} > /etc/image_info/python_packages.txt

RUN if [ -s /etc/image_info/bindep_build.txt ]; then \
        apt-get update \
        && DEBIAN_FRONTEND=noninteractive xargs --no-run-if-empty apt-get install -y --no-install-recommends < /etc/image_info/bindep_build.txt \
        && rm -rf /var/lib/apt/lists/*; \
    fi

RUN sed -i '/^python-openstackclient===/d' /upper-constraints.txt \
    && git clone --filter=blob:none -b ${OPENSTACKCLIENT_REF} ${OPENSTACKCLIENT_REPO} /tmp/python-openstackclient \
    && uv pip install \
         --build-constraint /upper-constraints.txt \
         -c /upper-constraints.txt \
         -r /etc/image_info/python_packages.txt \
         /tmp/python-openstackclient \
         aodhclient \
         cmd2 \
         gnocchiclient \
         osc-placement \
         python-barbicanclient \
         python-blazarclient \
         python-cinderclient \
         python-cloudkittyclient \
         python-cyborgclient \
         python-designateclient \
         python-freezerclient \
         python-glanceclient \
         python-heatclient \
         python-ironic-inspector-client \
         python-ironicclient \
         python-keystoneclient \
         python-magnumclient \
         python-manilaclient \
         python-masakariclient \
         python-mistralclient \
         python-neutronclient \
         python-novaclient \
         python-observabilityclient \
         python-octaviaclient \
         python-swiftclient \
         python-tackerclient \
         python-troveclient \
         python-vitrageclient \
         python-watcherclient \
         python-zaqarclient \
         python-zunclient \
         sqlalchemy \
    && git -C /tmp/python-openstackclient log --oneline -1 > /etc/image_info/project.txt \
    && rm -rf /tmp/python-openstackclient \
    && uv pip freeze > /etc/image_info/pip.txt

FROM ${BASE_RUNTIME} AS runtime

ENV PATH=/var/lib/openstack/bin:$PATH

COPY --from=build --link /var/lib/openstack /var/lib/openstack
COPY --from=build /etc/image_info /etc/image_info
COPY --from=build /upper-constraints.txt /

# Install packages determined by bindep in build stage
RUN if [ -s /etc/image_info/bindep_runtime.txt ]; then \
        apt-get update \
        && DEBIAN_FRONTEND=noninteractive xargs --no-run-if-empty apt-get install -y --no-install-recommends < /etc/image_info/bindep_runtime.txt \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# Ceph client tools (ceph, rados, rbd, radosgw-admin, cephfs tools,
# mount.ceph) and their python bindings, which the virtualenv sees through
# its system site packages.
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
         ceph-common \
         python3-cephfs \
         python3-rados \
         python3-rbd \
         s3cmd \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg-query -W -f='${Package}=${Version}\n' ceph-common > /etc/image_info/ceph.txt

RUN find /var/lib/openstack \( -name "*.pyc" -o -name "__pycache__" \) -delete \
    && rm -rf /tmp/* /root/.cache /etc/machine-id

# Fail the build if any tool is missing or does not run on this architecture
RUN set -ex \
    && openstack --version \
    && openstack command list > /dev/null \
    && ceph --version \
    && rados --version \
    && rbd --version \
    && radosgw-admin --version \
    && s3cmd --version \
    && python3 -c 'import cephfs, rados, rbd'

RUN groupadd -g 42424 openstacktools \
    && useradd -u 42424 -g 42424 -M -d /var/lib/openstacktools \
               -s /usr/sbin/nologin -c "openstack-tools user" openstacktools \
    && mkdir -p /etc/openstacktools /var/log/openstacktools \
                /var/lib/openstacktools /var/cache/openstacktools \
    && chown openstacktools:openstacktools \
         /etc/openstacktools /var/log/openstacktools \
         /var/lib/openstacktools /var/cache/openstacktools
