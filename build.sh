#!/bin/sh

rm -rf live-default
mkdir live-default
cd live-default || exit

lb_config='\
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --iso-volume "Gershwin"
    '

if [ -f "/__w/iso/iso/root_amd64.zip" ]; then
lb_config="$lb_config \\
    --image-name gershwin-amd64-$(date +"%Y%m%d%H%m") \\
    "
fi

if [ -f "/home/runner/work/iso/iso/root_arm64.zip" ]; then
lb_config="$lb_config \\
    --image-name gershwin-arm64-$(date +"%Y%m%d%H%m")
    --architectures arm64 \\
    --bootloader grub-efi \\
    --bootstrap-qemu-arch arm64 \\
    --bootstrap-qemu-static /usr/bin/qemu-arm-static \\
    ----verbose 3 \\
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

lb build