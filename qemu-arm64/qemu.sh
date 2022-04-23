#!/bin/bash

# qemu-system-aarch64 -nographic -machine gic-version=3 -bios u-boot.bin \
#	-cpu cortex-a53 -machine type=virt -smp 4 -m 2G -machine virtualization=true \
#	-D ./qemu.log -d  guest_errors\
#	-drive if=none,file=sd.img,format=raw,id=hd0 \
#	-device virtio-blk-device,drive=hd0

qemu-system-aarch64 -nographic -bios u-boot.bin \
	-M virtualization=on,gic-version=3 \
	-cpu cortex-a53 -machine type=virt -smp 4 -m 2G -machine virtualization=true \
	-drive if=none,file=sd.img,format=raw,id=hd0 \
	-device virtio-blk-device,drive=hd0 \
	-device virtio-net-device,netdev=net0 -netdev user,id=net0,hostfwd=tcp:127.0.0.1:5555-:22
