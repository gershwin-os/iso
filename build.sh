#!/bin/sh

rm -rf live-default
mkdir live-default
cd live-default || exit
lb config --distribution bookworm --archive-areas "main contrib non-free non-free-firmware" --iso-volume "Gershwin"

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