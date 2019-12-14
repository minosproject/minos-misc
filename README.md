# Minos

Minos is a flexible, open source, lightweight embedded real-time operating system that supports multi-core architecture and virtualization technology. It can support the integration of alternate workloads and simplify the development of IoT edge.

This git repository include all the Minos images for arm-fvp and Raspberry-pi-4, use these images, you can do some basic test for Minos virtualaztion features . 

```
# git clone https://github.com/minos-project/minos-release.git
```

Here we will use minos-releases as the working directory.

### Test Minos on Arm-fvp

- you need install the DS5 (I am using 5.27) or arm-fvp (Fixed Virtual Platforms), the below is the link which you can downloaded

  https://developer.arm.com/tools-and-software/simulation-models/fixed-virtual-platforms

  https://developer.arm.com/tools-and-software/embedded/legacy-tools/ds-5-development-studio

  please make sure you have install the FVP_Base_AEMv8A, this application is using to test minos on arm-fvp

- after install FVP_Base_AEMv8A, run below commands

  ```
  # cd v0.3/arm-fvp
  # ./run_fvp.sh
  ```

### Test Minos on Raspberry PI 4

***I only tested RPI4 4GB board***, if you have a 1G or 2G board, there is a way may make these boards work, but I did not try it. Minos will only register 0x0 - 0x3b400000 memory region to system automatically since u-boot do not pass correct memory information to the hypervisor, for the extra system memory, you can add it to /chosen/extra-memory in the dts, follow below steps:

```
# dtc -I dtb -O dts -o minos.dts v0.3/rpi-4/minos.dtb
```

the /chosen node's content will showed as below

```
        chosen {
                stdout-path = "serial0:115200n8";
                extra-memory = <0x40000000 0xbc000000>;
        };
```

modify the extra-memory information based on your board's information. **Note: if you are using 1G board, you may not able to create new guest VMs, since currently system will use all of the memory ( 0x0 - 0x3b400000) for native VM.**

after modify the memory information

```
# dtc -I dts -O dtb -o v0.3/rpi-4/minos.dtb minos.dts
```

Then please follow below steps to make Minos works on rpi4

- flash the **Raspbian** image to sd card, refer to RPI official guide

  https://www.raspberrypi.org/downloads/raspbian/

- copy all the images and config.txt to the boot partition, for example the boot partition will mount at /media/minle/boot

  ```
  # cp v0.3/rpi-4/config.txt /media/test/boot
  # cp v0.3/rpi-4/Image /media/test/boot
  # cp v0.3/rpi-4/kernel8.img /media/test/boot
  # cp v0.3/rpi-4/minos.bin /media/test/boot
  # cp v0.3/rpi-4/minos.dtb /media/test/boot
  # cp v0.3/rpi-4/vm0_dtb.img /media/test/boot
  # cp v0.3/rpi-4/vm1_dtb.img /media/test/boot
  # cp v0.3/rpi-4/vm1_ramdisk.img /media/test/boot
  ```

- copy the kernel modules to rootfs, the rootfs will mount at /media/minle/rootfs

  ```
  # sudo cp -r v0.3/rpi-4/4.19.76-v7l+ /media/minle/rootfs/lib/modules
  ```

- boot your rpi4 with new image and you'd better connect a uart to the rpi4

- wait for about 20 seconds, the board will boot successfully and you can connect the board to a monitor via HDMI cable, since all the hardware can work normally

- the default image will boot up 2 native VMs, one is VM0 which can control almost all the hardware device, another one is VM1, VM0 has 2 vcpus which are affinity to pcpu0 and pcpu1. VM1 has 1 vcpu which is affinity to pcpu2.

- using below command can open the ssh server and login into the system using ssh, for example the RPI4's IP address is 192.168.50.215

  ```
  # sudo systemctl start ssh (please use minicom to login into the system)
  # ssh pi@192.168.50.215 (the prssword is raspberry)
  ```

- using below command you can login into VM1

  ```
  # ssh pi@192.168.50.215
  # sudo minicom /dev/hvc1
  ```

- you can also create new VMs using user-space tool, copy the related image to the rootfs

  ```
  # scp v0.3/mvm/mvm_32bit virtio-image/virtio-sd.img guest_vm/aarch32-boot.imgguest_vm/aarch64-boot.img  pi@192.168.50.215:~

  # ssh pi@192.168.50.215
  ```

- below command is used to create a 64bit guest VM which has virtio-net, virtio-block and virtio console device

  ```
  # sudo ./mvm_32bit -c 1 -m 96M -i aarch64-boot.img -n elinux64 -t linux -b 64 -v -r -d --gicv2 --earlyprintk -V virtio_console,@pty: -V virtio_blk,/home/pi/minos/virtio-sd.img -V virtio_net,tap0 -C "console=hvc0 loglevel=8 consolelog=9 root=/dev/vda2 rw"
  ```

- below command is used to create a 32bit VM which has a virtio-console devcie

  ```
  # sudo ./mvm_32bit -c 1 -m 96M -i boot32.img -n elinux32 -t linux -b 32 -v -d --gicv2 --earlyprintk -V virtio_console,@pty: -C "console=hvc0 loglevel=8 consolelog=9"
  ```

**since we can not upload big file (> 100M) to github, you can download the virtio-sd.img from baidu disk.**

```
链接: https://pan.baidu.com/s/1Lmy_UBtaLw1IXcz9FbieaA 提取码: si73
```

