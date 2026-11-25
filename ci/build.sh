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
test ! -e srcpkgs/hyperv-daemons-lsvmbus
cp -a /overlay/srcpkgs/hyperv-daemons /overlay/srcpkgs/hyperv-daemons-lsvmbus srcpkgs/
chown -hR builder:builder srcpkgs/hyperv-daemons srcpkgs/hyperv-daemons-lsvmbus
printf '%s\n' XBPS_CHROOT_CMD=uchroot > etc/conf
chown builder:builder etc/conf
sudo -u builder ./xbps-src binary-bootstrap
sudo -u builder ./xbps-src pkg hyperv-daemons
. srcpkgs/hyperv-daemons/template
for name in hyperv-daemons hyperv-daemons-lsvmbus; do
    file="$name-$version"_"$revision.x86_64.xbps"
    test -s "hostdir/binpkgs/$file"
    cp "hostdir/binpkgs/$file" /out/
    xbps-query --repository="$PWD/hostdir/binpkgs" -R -f "$name"
done
cd /out
sha256sum ./*.xbps > SHA256SUMS
chmod a+r ./*.xbps SHA256SUMS
