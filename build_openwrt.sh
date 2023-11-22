#!/bin/bash

BASEDIR=$(realpath "$0" | xargs dirname)

OUTPUT="${BASEDIR}/images"
BUILD_VERSION="21.02.3"
BOARD_NAME="bcm27xx"
BOARD_SUBNAME="bcm2711"
BUILDER="https://downloads.openwrt.org/releases/${BUILD_VERSION}/targets/${BOARD_NAME}/${BOARD_SUBNAME}/openwrt-imagebuilder-${BUILD_VERSION}-${BOARD_NAME}-${BOARD_SUBNAME}.Linux-x86_64.tar.xz"
BUILDER_NAME="${BUILDER##*/}"
BUILDER_FOLDER="${BUILDER_NAME%.tar.xz}"
KERNEL_PARTSIZE=128 #Kernel-Partitionsize in MB
ROOTFS_PARTSIZE=4096 #Rootfs-Partitionsize in MB

# Search for any file named "openwrt-imagebuilder*" but not ${BUILDER_NAME} and delete it
find "${BASEDIR}" -maxdepth 1 -type f -name "openwrt-imagebuilder*" ! -name "${BUILDER_NAME}" -exec rm -rf {} \;

# Search for any directory containing the name openwrt-imagebuilder, named different than "${BUILDER##*/}" and delete it
find "${BASEDIR}" -maxdepth 1 -type d -name "openwrt-imagebuilder*" ! -name "${BUILDER_FOLDER}" -exec rm -rf {} \;

# download image builder if needed
if [ ! -f "${BUILDER_NAME}" ]; then
	wget "$BUILDER"
fi

# extract image builder if needed
if [ ! -d "${BUILDER_FOLDER}" ] && [ -f "${BUILDER_NAME}" ]; then
      tar xJvf "${BUILDER_NAME}"
fi

[ -d "${OUTPUT}" ] && { rm -rf "${OUTPUT}"; mkdir "${OUTPUT}"; } || { mkdir "${OUTPUT}"; }

cd "${BUILDER_FOLDER}"

make clean

# Packages are added if no prefix is given, '-packaganame' does not integrate a package
sed -i "s/CONFIG_TARGET_KERNEL_PARTSIZE=.*/CONFIG_TARGET_KERNEL_PARTSIZE=$KERNEL_PARTSIZE/g" .config
sed -i "s/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE/g" .config

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	make image  PROFILE="rpi-4" \
           PACKAGES="bash kmod-rt2800-usb rt2800-usb-firmware kmod-cfg80211 kmod-lib80211 kmod-mac80211 kmod-rtl8192cu \
                     base-files block-mount fdisk luci-app-minidlna minidlna samba4-server \
                     samba4-libs luci-app-samba4 wireguard-tools luci-app-wireguard \
                     openvpn-openssl luci-app-openvpn watchcat openssh-sftp-client \
                     luci-base luci-ssl luci-mod-admin-full luci-theme-bootstrap bcm27xx-eeprom \
                     kmod-usb-storage kmod-usb-ohci kmod-usb-uhci e2fsprogs fdisk resize2fs \
                     htop debootstrap luci-compat luci-lib-ipkg dnsmasq luci-app-ttyd \
                     irqbalance ethtool netperf speedtest-netperf iperf3 \
                     curl wget rsync file htop lsof less mc tree usbutils bash diffutils \
                     openssh-sftp-server nano luci-app-ttyd kmod-fs-exfat \
                     kmod-usb-storage block-mount luci-app-minidlna kmod-fs-ext4 \
                     urngd usign vpn-policy-routing wg-installer-client wireguard-tools \
                     kmod-usb-core kmod-usb3 dnsmasq dropbear e2fsprogs \
                     zlib firewall wireless-regdb f2fsck openssh-sftp-server \
                     kmod-usb-wdm kmod-usb-net-ipheth usbmuxd kmod-usb-net-asix-ax88179 \
                     kmod-usb-net-cdc-ether mount-utils kmod-rtl8xxxu kmod-rtl8187 \
                     kmod-rtl8xxxu rtl8188eu-firmware kmod-rtl8192ce kmod-rtl8192cu kmod-rtl8192de \
                     adblock luci-app-adblock kmod-fs-squashfs squashfs-tools-unsquashfs squashfs-tools-mksquashfs \
                     kmod-fs-f2fs kmod-fs-vfat git git-http jq wget-ssl unzip ca-bundle ca-certificates" \
            FILES="${BASEDIR}/files/" \
            BIN_DIR="${OUTPUT}"