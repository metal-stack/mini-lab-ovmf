# See https://fabianlee.org/2018/09/12/kvm-building-the-latest-ovmf-firmware-for-virtual-machines/
FROM docker.io/debian:bookworm-backports AS build

RUN apt-get update && \
    apt-get install --yes \
        build-essential \
        git \
        uuid-dev \
        iasl \
        nasm \
        python3-dev \
        python-is-python3

ARG EDK2_TAG=edk2-stable202408.01

RUN git clone --depth 1 "https://github.com/tianocore/edk2.git" -b ${EDK2_TAG} --recurse-submodules --shallow-submodules

WORKDIR /edk2

SHELL ["/bin/bash", "-c"]

RUN source ./edksetup.sh && \
    make -C BaseTools/ && \
    build -a X64 -t GCC5 -b RELEASE -p OvmfPkg/OvmfPkgX64.dsc \
          -DBUILD_SHELL=FALSE \
          -DNETWORK_IP4_ENABLE=TRUE \
          -DNETWORK_IP6_ENABLE=FALSE \
          -DNETWORK_HTTP_BOOT_ENABLE=FALSE \
          -DNETWORK_VLAN_ENABLE=FALSE

FROM scratch

COPY --from=build /edk2/Build/OvmfX64/RELEASE_GCC5/FV/OVMF_*.fd /
