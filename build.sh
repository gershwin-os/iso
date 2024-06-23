#!/bin/sh

# Exit immediately if any command exits with a non-zero status
set -e

# Initialize WORKDIR to empty (if not already set)
export WORKDIR=""

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

if [ -d "/home/runner/work/iso/iso/" ]; then
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
if [ -d "/__w/iso/iso/" ]; then
  cp /__w/iso/iso/config/package-lists/gershwin.list.chroot config/package-lists/gershwin.list.chroot
  tar -xf /__w/iso/iso/system-amd64.tar.gz -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /__w/iso/iso/developer-amd64.tar.gz -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /__w/iso/iso/applications-amd64.tar.gz -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/Applications
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/Developer/Applications
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/System/Applications
  # Fetch and extract overlays
  wget -O opt.zip https://github.com/gershwin-os/opt/archive/refs/heads/main.zip
  wget -O etc.zip https://github.com/gershwin-os/etc/archive/refs/heads/main.zip
  wget -O desktop-pictures.zip https://github.com/gershwin-os/desktop-pictures/archive/refs/heads/main.zip
  mkdir -p /__w/iso/iso/live-default/config/includes.chroot_after_packages/etc
  mkdir -p /__w/iso/iso/live-default/config/includes.chroot_after_packages/opt
  mkdir -p /__w/iso/iso/live-default/config/includes.chroot_after_packages/System/Library/Desktop\ Pictures/
  bsdtar -xf opt.zip -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/opt/ --strip-components 1 --exclude 'LICENSE' --exclude 'README.md'
  bsdtar -xf etc.zip -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/etc/ --strip-components 1 --exclude 'LICENSE' --exclude 'README.md'
  bsdtar -xf desktop-pictures.zip -C /__w/iso/iso/live-default/config/includes.chroot_after_packages/System/Library/Desktop\ Pictures/ --strip-components 1 --exclude 'README.md'
  chmod +x /__w/iso/iso/live-default/config/includes.chroot_after_packages/opt/bin/*
  ls /__w/iso/iso/live-default/config/includes.chroot_after_packages/opt/
fi

# Modify package list and extract GNUstep for ARM64
if [ -d "/home/runner/work/iso/iso/" ]; then
  cp /home/runner/work/iso/iso/config/package-lists/gershwin.list.chroot config/package-lists/gershwin.list.chroot
  tar -xf /home/runner/work/iso/iso/system-arm64.tar.gz -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /home/runner/work/iso/iso/developer-arm64.tar.gz -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  tar -xf /home/runner/work/iso/iso/applications-arm64.tar.gz -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  ls /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/
  ls /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/Applications
  ls /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/Developer/Applications
  ls /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/System/Applications
  # Fetch and extract overlays
  wget -O opt.zip https://github.com/gershwin-os/opt/archive/refs/heads/main.zip
  wget -O etc.zip https://github.com/gershwin-os/etc/archive/refs/heads/main.zip
  wget -O desktop-pictures.zip https://github.com/gershwin-os/desktop-pictures/archive/refs/heads/main.zip
  mkdir -p /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/etc
  mkdir -p /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/opt
  mkdir -p /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/System/Library/Desktop\ Pictures/
  bsdtar -xf opt.zip -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/opt/ --strip-components 1 --exclude 'LICENSE' --exclude 'README.md'
  unzip etc.zip -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/etc/ --strip-components 1 --exclude 'LICENSE' --exclude 'README.md'
  unzip desktop-pictures.zip -C /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/System/Library/Desktop\ Pictures/ --strip-components 1 --exclude 'README.md'
  chmod +x /home/runner/work/iso/iso/live-default/config/includes.chroot_after_packages/opt/bin/*
fi

cat <<EOF > config/hooks/live/gershwin.hook.chroot
#!/bin/sh

set -e

# This script is run inside the ISO chroot after packages
git clone https://github.com/gnustep/tools-scripts /tools-scripts
cd / && ./tools-scripts/install-dependencies-linux

EOF

lb build