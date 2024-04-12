#!/bin/sh

rm -rf live-default
mkdir live-default
cd live-default || exit

lb_config=" \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --iso-volume "Gershwin"
    "

if [ -f "/home/runner/work/iso/iso/root_arm64.zip" ]; then
lb_config="$lb_config \
    --architectures arm64 \
    --bootloader grub-efi \
    --bootstrap-qemu-arch arm64 \
    --bootstrap-qemu-static /usr/bin/qemu-arm-static \
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