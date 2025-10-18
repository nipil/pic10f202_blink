# PIC10F202 blink using Debian and K150 programmer


Plug your K150 in the Debian VM or desktop or server

Verify that it is correctly seen by the OS :

    sudo dmesg

Look for the USB stuff, and the `pl2303` which is what the K150 used to use :

    [1373310.459289] usb 1-2: new full-speed USB device number 3 using xhci_hcd
    [1373310.608360] usb 1-2: New USB device found, idVendor=067b, idProduct=2303, bcdDevice= 3.00
    [1373310.608375] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
    [1373310.608382] usb 1-2: Product: USB-Serial Controller
    [1373310.608387] usb 1-2: Manufacturer: Prolific Technology Inc.
    [1373310.614112] pl2303 1-2:1.0: pl2303 converter detected
    [1373310.615092] usb 1-2: pl2303 converter now attached to ttyUSB0

Verify what group is the owner of the `ttyUSB0` device

    stat /dev/ttyUSB0

Look for the `Gid` field :

    File: /dev/ttyUSB0
    Size: 0               Blocks: 0          IO Block: 4096   character special file
    Device: 0,5     Inode: 785         Links: 1     Device type: 188,0
    Access: (0660/crw-rw----)  Uid: (    0/    root)   Gid: (   20/ dialout)
    Access: 2025-10-17 15:30:15.251700585 +0200
    Modify: 2025-10-17 15:30:15.251700585 +0200
    Change: 2025-10-17 15:30:15.251700585 +0200
    Birth: 2025-10-17 15:30:15.223700774 +0200

Ensure that your user is part of that owning group

    sudo usermod -a -G dialout $USER

IMPORTANT: Logout and reconnect from your desktop or ssh session or the added group will not be applied and you will not be able to use the programming device

Start a throwaway development container to not pollute your host :

    podman run --rm --group-add keep-groups -v .:/pic -v /dev/ttyUSB0:/dev/ttyUSB0 --pull always -it debian:trixie-slim

Go to the source folder

    cd /pic

Install the required tools for the job

    ./setup.sh

Edit your assembly files, and then compile it for the selected target microcontroller

    make build
