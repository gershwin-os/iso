# Gershwin ISO

This repository automates the build of Gershwin Installation media.

### Requirements

* Debain 12
* live-build
* qemu-user-static (for ARM64)

## Building the ISO

Follow these steps to install Applications on Debian:

1. Clone the repository with submodules:

```
git clone https://github.com/gershwin-os/iso.git
```

2. Build the components:
```
cd iso && sudo ./build.sh
```

