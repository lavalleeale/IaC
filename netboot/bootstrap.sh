#!/usr/bin/env bash
export YOURMIRROR=deb.debian.org
export ARCH=amd64
export DIST=stable
if ! ls data/debian/{linux,initrd.gz} data/bootnetx64.efi data/font.pf2 >/dev/null 2>&1; then
    wget http://"$YOURMIRROR"/debian/dists/$DIST/main/installer-"$ARCH"/current/images/netboot/netboot.tar.gz -O data/debian/netboot.tar.gz
    tar -zxvf data/debian/netboot.tar.gz -C data/debian --strip-components=3 ./debian-installer/amd64/{linux,initrd.gz}
    tar -zxvf data/debian/netboot.tar.gz -C data --strip-components=3 ./debian-installer/amd64/bootnetx64.efi
    tar -zxvf data/debian/netboot.tar.gz -C data --strip-components=4 ./debian-installer/amd64/grub/font.pf2
    rm data/debian/netboot.tar.gz
fi
if ! ls data/ubuntu/{initrd,vmlinuz} >/dev/null 2>&1; then
    if [ ! -f data/ubuntu/ubuntu-22.04.2-live-server-amd64.iso ]; then
        wget https://releases.ubuntu.com/jammy/ubuntu-22.04.2-live-server-amd64.iso -O data/ubuntu/ubuntu-22.04.2-live-server-amd64.iso
        7z e data/ubuntu/ubuntu-22.04.2-live-server-amd64.iso -odata/ubuntu casper/{vmlinuz,initrd} -r -aoa
        rm data/ubuntu/ubuntu-22.04.2-live-server-amd64.iso
    else
        7z e data/ubuntu/ubuntu-22.04.2-live-server-amd64.iso -odata/ubuntu casper/{vmlinuz,initrd} -r -aoa
    fi
fi

if [ ! -f data/grubx64.efi ]; then
    wget http://security.ubuntu.com/ubuntu/pool/main/g/grub2-signed/grub-efi-amd64-signed_1.173.2~20.04.1+2.04-1ubuntu47.4_amd64.deb -O grub.deb
    dpkg-deb --fsys-tarfile grub.deb | tar x ./usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed -O >data/grubx64.efi
    rm grub.deb
fi
