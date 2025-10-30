# PIC10F202 blink using Debian and K150 programmer

## Device for K150 programmer

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

## Enabling K150 device into a throwaway container

Start a throwaway development container to not pollute your host :

    podman run --rm --group-add keep-groups -v .:/pic -v /dev/ttyUSB0:/dev/ttyUSB0 --pull always -it debian:trixie-slim

Go to the source folder

    cd /pic

If you want to install the latest development version, otherwise skip this command

    export PIP_PICPRO='git+https://github.com/Salamek/picpro.git@master'

Install the required tools for the job

    ./setup.sh

Get offline information about your chip

    make chipinfo

    {"chip_name": "10f202", "include": true, "socket_image": "0pin", "erase_mode": 6, "flash_chip": true, "power_sequence": "VccVpp1", "program_delay": 20, "program_tries": 1, "over_program": 0, "core_type": "newf12b", "rom_size": 512, "eeprom_size": 0, "fuse_blank": [4095], "cp_warn": false, "cal_word": true, "band_gap": false, "icsp_only": true, "chip_id": 65535, "fuses": {"WDT": {"Enabled": [[0, 16383]], "Disabled": [[0, 16379]]}, "Code Protect": {"Disabled": [[0, 16383]], "Enabled": [[0, 16375]]}, "MCLRE": {"Enabled": [[0, 16383]], "Disabled": [[0, 16367]]}}}

Offline decode of fuses

    make decode_default_fuses
    picpro decode_fuses 4095 -t 10f202
    {'WDT': 'Enabled', 'Code Protect': 'Disabled', 'MCLRE': 'Enabled'}

Verify the communication with your programmer

    make proginfo
    picpro programmer_info -p /dev/ttyUSB0
    Firmware version: 3
    Protocol version: P018

Read chip config (here the PIC10F202 requires ICSP, according to microbrn.exe)

    make read_config
    picpro read_chip_config -p /dev/ttyUSB0 -t 10f202 --icsp
    Opening connection to programmer...
    Initializing programming interface...
    Chip ID: 65535 (0xffff)
    ID:      ffffffffffffffff
    CAL:     65535
    Fuses:
        WDT = Disabled
        Code Protect = Disabled
        MCLRE = Disabled
    Done!

Dump the current content of your chip

    make dump
    picpro dump rom -p /dev/ttyUSB0 -t 10f202 -o dump-rom.hex
    Opening connection to programmer...
    Initializing programming interface...
    Reading ROM into file dump-rom.hex...
    Done!
    picpro dump eeprom -p /dev/ttyUSB0 -t 10f202 -o dump-eeprom.hex
    Opening connection to programmer...
    Initializing programming interface...
    This chip has no EEPROM!
    picpro dump config -p /dev/ttyUSB0 -t 10f202 -o dump-config.hex
    Opening connection to programmer...
    Initializing programming interface...
    Reading CONFIG into file dump-config.hex...
    Done!

Erase your chip

    make erase
    picpro erase -p /dev/ttyUSB0 -t 10f202 --icsp
    Opening connection to programmer...
    Initializing programming interface...
    Erasing chip...
    Done!

Edit your assembly files, and then compile it for the selected target microcontroller

    make build

Get information about your hex file

    make hexinfo
    picpro hex_info 10f202.hex 10f202
    ROM 22 words used, 490 words free on chip.
    EEPROM 0 bytes used, 0 bytes free on chip.
    data:
    - { first: 0x00000000, last: 0x0000002B, length: 0x0000002C }
    - { first: 0x00001FFE, last: 0x00001FFF, length: 0x00000002 }

Program your chip (**FAILS at the moment**)

    make prog
    picpro program -p /dev/ttyUSB0 -i 10f202.hex -t 10f202 --icsp
    Opening connection to programmer...
    Initializing programming interface...
    ==== Chip info ====
    Chip ID: 65535 (0xffff)
    ID:      ffffffffffffffff
    CAL:     65535
    Fuses:
        WDT = Disabled
        Code Protect = Disabled
        MCLRE = Disabled
    CAL is in ROM data, patching ROM to contain the same CAL data...
    Erasing chip.
    Done!
    Programming ROM.
    Traceback (most recent call last):
    File "/usr/local/bin/picpro", line 8, in <module>
        sys.exit(main())
                ~~~~^^
    File "/root/venv/lib/python3.13/site-packages/picpro/bin/picpro.py", line 532, in main
        getattr(command, 'chosen')()  # Execute the function specified by the user.
        ~~~~~~~~~~~~~~~~~~~~~~~~~~^^
    File "/root/venv/lib/python3.13/site-packages/picpro/bin/picpro.py", line 228, in program
        programming_interface.program_rom(flash_data.rom_data)
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^
    File "/root/venv/lib/python3.13/site-packages/picpro/protocol/p18a/ProgrammingInterface.py", line 120, in program_rom
        self.connection.expect(b'P', timeout=20)
        ~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^
    File "/root/venv/lib/python3.13/site-packages/picpro/protocol/IConnection.py", line 56, in expect
        raise InvalidResponseError('Expected "{!r}", received {!r}.'.format(expected, response))
    picpro.exceptions.InvalidResponseError: Expected "b'P'", received b'N'.
    make: *** [Makefile:46: prog] Error 1

Verify your programming (**FAILS at the moment**)

    make verify
    picpro verify -p /dev/ttyUSB0 -i 10f202.hex -t 10f202 --icsp
    Opening connection to programmer...
    Initializing programming interface...
    Chip config: ChipConfig(chip_id=65535, id=b'\xff\xff\xff\xff\xff\xff\xff\xff', fuses=[4075, 65535, 65535, 65535, 65535, 65535, 65535], calibrate=65535)
    CAL is in ROM data, patching ROM to contain the same CAL data...
    Verifying ROM.
    ROM verification failed.
    Done!

## Optional : upgrading the K150 firmware

In case your K150 needs it, plug another PIC16F628A with pin 1 in ZIF pin 2, and get and programm the latest firmware :

    curl -qq -Ss -L -o k150-v25a-P018.hex https://github.com/Salamek/picpro/blob/c671a925db8cd28f10750985b08eae99468e7fa7/firmwares/Firmware%20v25a%20(Protocol%20P018)/k150.hex
    picpro program -p /dev/ttyUSB0 -i k150-v25a-P018.hex -t 16F628A

    Waiting for user to insert chip into socket with pin 1 at socket pin 2
    Chip detected.
    Chip config: {'chip_id': 4198, 'id': b'\x0f\x0f\x0f\x0f\xff\xff\xff\xff', 'fuses': [7978, 16383, 16383, 65535, 65535, 65535, 65535], 'calibrate': 65535}
    Erasing chip.
    Programming ROM.
    Programming EEPROM.
    Programming ID and fuses.
    Verifying ROM.
    ROM verified.
    Verifying EEPROM.
    EEPROM verified.

Then swap the two chips.
