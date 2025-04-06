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

if [[ ! -d ${WORK_DIR}/openwrt_build_config ]];then
    git clone https://github.com/sunowsir/openwrt_build_config.git || exit
fi

if [[ ! -d ${WORK_DIR}/feeds.conf.default ]]; then
    git clone https://github.com/sunowsir/feeds.conf.default.git || exit 
fi

if [[ ! -d ${WORK_DIR}/openwrt_patch ]]; then
    git clone https://github.com/sunowsir/openwrt_patch.git || exit 
fi

if [[ ! -d ${BUILD_DIR} ]]; then
    git clone -b openwrt-24.10 https://git.openwrt.org/openwrt/openwrt.git || exit 
fi

cp "${WORK_DIR}/feeds.conf.default/feeds.conf.default" "${BUILD_DIR}" || exit

cp -r "${WORK_DIR}/openwrt_qcow2_build_support/*" "${BUILD_DIR}" || exit

cd "${BUILD_DIR}" || exit

git pull && ./scripts/feeds update -a && ./scripts/feeds install -a
git pull && ./scripts/feeds update -a && ./scripts/feeds install -a
git pull && ./scripts/feeds update -a && ./scripts/feeds install -a

cp "${WORK_DIR}/openwrt_build_config/config.buildinfo" "${BUILD_DIR}/.config" || exit

make defconfig || exit 

make -j12 download || make -j12 download PKG_HASH=skip || exit

make -j12 prepare  || exit 

make -j12 || make -j12 PKG_HASH=skip || exit 

set +x 

