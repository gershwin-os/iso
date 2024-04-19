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

# Modify package list extract GNUstep for AMD64
if [ -f "/__w/iso/iso/root_amd64.zip" ]; then
  cp /__w/iso/iso/config/package-lists/gershwin.list.chroot config/package-lists/gershwin.list.chroot
  tar -xf /__w/iso/iso/root-amd64.tar.gz -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /__w/iso/iso/system-amd64.tar.gz -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /__w/iso/iso/developer-amd64.tar.gz -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /__w/iso/iso/applications-amd64.tar.gz -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/Applications
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/Developer/Applications
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/System/Applications
fi

# Modify package list and extract GNUstep for ARM64
if [ -f "/home/runner/work/iso/iso/root_arm64.zip" ]; then
  cp /home/runner/work/iso/iso/config/package-lists/gershwin.list.chroot config/package-lists/gershwin.list.chroot
  tar -xf /home/runner/work/iso/iso/root-arm64.tar.gz -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /home/runner/work/iso/iso/system-arm64.tar.gz -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /home/runner/work/iso/iso/developer-arm64.tar.gz -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /home/runner/work/iso/iso/applications-arm64.tar.gz -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  ls /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  ls /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/Applications
  ls /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/Developer/Applications
  ls /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/System/Applications
fi

cat <<EOF > config/hooks/live/gershwin.hook.chroot
#!/bin/sh

set -e

# This script is run inside the ISO chroot after packages
git clone https://github.com/gnustep/tools-scripts /tools-scripts
cd / && ./tools-scripts/install-dependencies-linux

EOF

lb build