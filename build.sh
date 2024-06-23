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
  echo "WORKDIR is empty, setting it to current working directory"
  WORKDIR="$PWD"
fi

echo "WORKDIR is set to: $WORKDIR"

rm -rf live-default
mkdir live-default
cd live-default || exit

lb_config=" \
    --distribution bookworm \
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

echo "xorg" > config/package-lists/gershwin.list.chroot
echo "git" > config/package-lists/gershwin.list.chroot

# Modify package list extract GNUstep
cp ${WORKDIR}/config/package-lists/gershwin.list.chroot config/package-lists/gershwin.list.chroot
tar -xf ${WORKDIR}/system-${ARCH}.tar.gz -C ${WORKDIR}/live-default/config/includes.chroot_after_packages/
tar -xf ${WORKDIR}/developer-${ARCH}.tar.gz -C ${WORKDIR}/live-default/config/includes.chroot_after_packages/
tar -xf ${WORKDIR}/applications-${ARCH}.tar.gz -C ${WORKDIR}/live-default/config/includes.chroot_after_packages/
ls ${WORKDIR}/live-default/config/includes.chroot_after_packages/
ls ${WORKDIR}/live-default/config/includes.chroot_after_packages/Applications
ls ${WORKDIR}/live-default/config/includes.chroot_after_packages/Developer/Applications
ls ${WORKDIR}/live-default/config/includes.chroot_after_packages/System/Applications
# Fetch and extract overlays
wget -O opt.zip https://github.com/gershwin-os/opt/archive/refs/heads/main.zip
wget -O etc.zip https://github.com/gershwin-os/etc/archive/refs/heads/main.zip
wget -O desktop-pictures.zip https://github.com/gershwin-os/desktop-pictures/archive/refs/heads/main.zip
mkdir -p ${WORKDIR}/live-default/config/includes.chroot_after_packages/etc
mkdir -p ${WORKDIR}/live-default/config/includes.chroot_after_packages/opt
mkdir -p ${WORKDIR}/live-default/config/includes.chroot_after_packages/System/Library/Desktop\ Pictures/
bsdtar -xf opt.zip -C ${WORKDIR}/live-default/config/includes.chroot_after_packages/opt/ --strip-components 1 --exclude 'LICENSE' --exclude 'README.md'
bsdtar -xf etc.zip -C ${WORKDIR}/live-default/config/includes.chroot_after_packages/etc/ --strip-components 1 --exclude 'LICENSE' --exclude 'README.md'
bsdtar -xf desktop-pictures.zip -C ${WORKDIR}/live-default/config/includes.chroot_after_packages/System/Library/Desktop\ Pictures/ --strip-components 1 --exclude 'README.md'
chmod +x ${WORKDIR}/live-default/config/includes.chroot_after_packages/opt/bin/*
ls ${WORKDIR}/live-default/config/includes.chroot_after_packages/opt/


cat <<EOF > config/hooks/live/gershwin.hook.chroot
#!/bin/sh

set -e

# This script is run inside the ISO chroot after packages
git clone https://github.com/gnustep/tools-scripts /tools-scripts
cd / && ./tools-scripts/install-dependencies-linux

EOF

lb build