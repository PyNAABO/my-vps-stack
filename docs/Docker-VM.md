# 🐳 Running Real Docker on Termux (QEMU)

If you need `docker-compose` support on Android without root, you must run a Virtual Machine.

> [!WARNING]
> This is significantly slower than the native [Termux.md](./Termux.md) method and uses more battery. Only use this if you need an app that only exists as a Docker container.

## 1. Setup QEMU

```bash
pkg install qemu-utils qemu-common qemu-system-aarch64-headless
```

## 2. Initialize Alpine VM

1. Download Alpine Virtual ISO (ARM64):
   ```bash
   mkdir ~/docker-vm && cd ~/docker-vm
   wget https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/aarch64/alpine-virt-3.19.1-aarch64.iso
   ```
2. Create Sparse Disk:
   ```bash
   # Starts at ~0MB, grows as needed.
   qemu-img create -f qcow2 docker.qcow2 10G
   ```

## 3. Installation

Boot from ISO:

```bash
qemu-system-aarch64 -M virt -cpu max -m 2G -drive file=docker.qcow2,if=virtio -cdrom alpine-virt-3.19.1-aarch64.iso -netdev user,id=n1,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=n1 -nographic
```

Log in as `root` and run `setup-alpine`. Choose `vda` for disk and `sys` for mode.

## 4. Run Docker

Inside the VM (after setup):

```bash
apk add docker docker-compose
rc-update add docker boot
service docker start
```

## 5. Port Forwarding

To access your apps from your phone's browser, you must add `hostfwd` flags to your QEMU start command for each port (e.g., `hostfwd=tcp::8080-:8080`).
