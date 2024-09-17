#!/bin/sh

# Exit immediately if any command exits with a non-zero status
set -e

# Initialize WORKDIR to empty (if not already set)
export WORKDIR=""

# Determine the architecture of the Linux builder
ARCH=$(dpkg --print-architecture)

# Detect whether or not GitHub actions is being used
if [ -d "/__w/iso/iso/" ]; then
  echo "GH actions AMD64 runner detected"
  export WORKDIR="/__w/iso/iso/"
fi

if [ -d "/home/runner/work/iso/iso/" ]; then
  echo "GH actions ARM64 runner detected"
  export WORKDIR="/home/runner/work/iso/iso/"
fi

if [ -z "$WORKDIR" ]; then
  echo "WORKDIR is empty, setting it to current working directory and setup for local building"
  WORKDIR="$PWD"
  [ -d "${WORKDIR}/system" ] && rm -rf "${WORKDIR}/system"
  cd ${WORKDIR} && git clone https://github.com/gershwin-os/system.git --recurse-submodules
  cd ${WORKDIR}/system && ./tools-scripts/install-dependencies-linux && make uninstall && make install
  mv ${WORKDIR}/system/system.txz ${WORKDIR}
  [ -d "${WORKDIR}/applications" ] && rm -rf "${WORKDIR}/applications"
  cd ${WORKDIR} && git clone https://github.com/gershwin-os/applications.git --recurse-submodules
  cd ${WORKDIR}/applications && make uninstall && make install
  mv ${WORKDIR}/applications/applications.txz ${WORKDIR}
fi

echo "WORKDIR is set to: $WORKDIR"

cd ${WORKDIR}
rm -rf live-default
mkdir live-default
cd live-default || exit

lb_config=" \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --image-name gershwin-$(date +"%Y%m%d%H%m") \
    --iso-volume "'"Gershwin"'"
    "

if [ "${ARCH}" = "arm64" ]; then
lb_config="$lb_config \
    --architectures arm64 \
    --bootloader grub-efi \
    --bootstrap-qemu-arch arm64 \
    --bootstrap-qemu-static /usr/bin/qemu-arm-static
    "
fi

echo "Config is ${lb_config}"

lb config $lb_config

# Modify package list extract GNUstep
cp -R ../config/* config/
tar -xf ${WORKDIR}/system.txz -C ${WORKDIR}/live-default/config/includes.chroot_after_packages/
tar -xf ${WORKDIR}/applications.txz -C ${WORKDIR}/live-default/config/includes.chroot_after_packages/
cp -R ${WORKDIR}/overlay/* ${WORKDIR}/live-default/config/includes.chroot_after_packages/

cat <<EOF > config/hooks/live/gershwin.hook.chroot
#!/bin/sh

set -e

# This script is run inside the ISO chroot after packages
git clone https://github.com/gnustep/tools-scripts /tools-scripts
cd / && ./tools-scripts/install-dependencies-linux

EOF

lb build