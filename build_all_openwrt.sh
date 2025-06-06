#!/bin/bash
#
#    * File     : build_all_openwrt.sh
#    * Author   : sunowsir
#    * Mail     : sunowsir@163.com
#    * Github   : github.com/sunowsir
#    * Creation : Sat 29 Mar 2025 04:54:00 PM CST

set -x

WORK_DIR="$(dirname "$(readlink -f "${0}")")"
BUILD_DIR="${WORK_DIR}/openwrt"

if [[ ! -d ${WORK_DIR}/openwrt_patch ]]; then
    git clone https://github.com/sunowsir/openwrt_patch.git || exit 
else 
    cd "${WORK_DIR}/openwrt_patch" || exit
    git pull || exit
    cd "${WORK_DIR}" || exit
fi

if [[ ! -d ${BUILD_DIR} ]]; then
    git clone -b openwrt-24.10 https://git.openwrt.org/openwrt/openwrt.git || exit 
else 
    cd "${BUILD_DIR}" || exit
    git pull  || exit
    cd "${WORK_DIR}" || exit
fi

cp "${WORK_DIR}"/openwrt_patch/patch/feeds.conf.default "${BUILD_DIR}/" || exit

sed -i  's/\/bin\/ash/\/usr\/bin\/fish/g' ${BUILD_DIR}/feeds/base/base-files/files/etc/passwd

cd "${BUILD_DIR}" || exit

./scripts/feeds update -a && ./scripts/feeds install -a
./scripts/feeds update -a && ./scripts/feeds install -a
./scripts/feeds update -a && ./scripts/feeds install -a

cp -r "${WORK_DIR}"/openwrt_patch/patch/* "${BUILD_DIR}/" || exit

make defconfig || exit 

make -j"$(nproc)" download || exit

make -j"$(nproc)" prepare  || exit 

make -j"$(nproc)" || exit 

set +x 

