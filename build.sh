#!/bin/sh

# Get the machine architecture
arch=$(uname -m)

uname -a
uname -m

# Check if it's a 64-bit ARM system
if [ "$arch" = "aarch64" ]; then
    export LB_BUILD_ARCH="arm64"
# Check if it's a 64-bit Intel system
elif [ "$arch" = "x86_64" ]; then
    export LB_BUILD_ARCH=ARCHITECTURE="amd64"
else
    echo "Unsupported architecture: $arch"
    exit 1
fi

rm -rf live-default
mkdir live-default
cd live-default || exit

lb_config='\
    --distribution bookworm \
    --architectures $LB_BUILD_ARCH \
    --archive-areas "main contrib non-free non-free-firmware" \
    --iso-volume "Gershwin"
    '
if [ "$LB_BUILD_ARCH" == 'arm64' ]; then
lb_config="$lb_config \\
    --bootloader grub-efi \\
    --bootstrap-qemu-arch arm64 \\
    --bootstrap-qemu-static /usr/bin/qemu-arm-static \\
    "
fi

echo "Config is ${lb_config}"

lb config $lb_config

echo "xorg" > config/package-lists/gershwin.list.chroot
pwd
ls -la ..
#cp -R ../overlay/* config/includes.chroot_after_packages/

cat <<EOF > config/hooks/live/gershwin.hook.chroot
#!/bin/sh

set -e

# This script is run inside the ISO chroot after packages

EOF

# lb build