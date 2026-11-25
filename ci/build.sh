#!/bin/sh
set -eu
xbps-install -Suy xbps
xbps-install -uy
xbps-install -y git sudo bash
useradd -m -G xbuilder builder
mkdir -p /build
chown builder:builder /build
cd /build
sudo -u builder git init void-packages
cd void-packages
sudo -u builder git remote add origin https://github.com/void-linux/void-packages.git
sudo -u builder git fetch --depth=1 origin eae7925433cd7822dff9be771d6738d4492a49b5
sudo -u builder git checkout --detach FETCH_HEAD
test ! -e srcpkgs/hyperv-daemons
cp -a /overlay/srcpkgs/hyperv-daemons srcpkgs/
chown -hR builder:builder srcpkgs/hyperv-daemons
printf '%s\n' XBPS_CHROOT_CMD=uchroot > etc/conf
chown builder:builder etc/conf
sudo -u builder ./xbps-src binary-bootstrap
sudo -u builder ./xbps-src pkg hyperv-daemons
# Read the built package version from XBPS metadata, not by sourcing
# an xbps-src template outside its build environment.
repo="$PWD/hostdir/binpkgs"
name=hyperv-daemons
pkgver=$(xbps-query --repository="$repo" -R -p pkgver "$name")
case "$pkgver" in
    "$name"-[0-9]*) ;;
    *) printf 'Unexpected pkgver: %s\n' "$pkgver" >&2; exit 1 ;;
esac
file="$pkgver.x86_64.xbps"
test -s "$repo/$file"
xbps-query --repository="$repo" -R -f "$name" > /tmp/hyperv-package-files
cat /tmp/hyperv-package-files
for path in /usr/bin/hv_kvp_daemon /usr/bin/hv_vss_daemon /usr/bin/hv_fcopy_uio_daemon /usr/bin/lsvmbus /etc/sv/hv-kvp-daemon/run /etc/sv/hv-vss-daemon/run; do
    grep -Fx "$path" /tmp/hyperv-package-files
done
cp "$repo/$file" /out/
cd /out
sha256sum ./*.xbps > SHA256SUMS
chmod a+r ./*.xbps SHA256SUMS
