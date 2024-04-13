#!/bin/sh

rm -rf live-default
mkdir live-default
cd live-default || exit

lb_config=" \
    --distribution bookworm \
    --image-name gershwin-$(date +"%Y%m%d%H%m") \
    --iso-volume "'"Gershwin"'"
    "

if [ -f "/home/runner/work/iso/iso/root_arm64.zip" ]; then
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

# Extract GNUstep for AMD64
if [ -f "/__w/iso/iso/root_amd64.zip" ]; then
  tar -xf /__w/iso/iso/root-amd64.tar.gz -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/
fi

# Extract GNUstep for ARM64
if [ -f "/home/runner/work/iso/iso/root_arm64.zip" ]; then
  tar -xf /home/runner/work/iso/iso/root-arm64.tar.gz -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
fi

cat <<EOF > config/hooks/live/gershwin.hook.chroot
#!/bin/sh

set -e

# This script is run inside the ISO chroot after packages
git clone https://github.com/gnustep/tools-scripts /tools-scripts
cd / && ./tools-scripts/install-dependencies-linux

EOF

lb build