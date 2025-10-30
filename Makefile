PHONY: build

all: build

chip=10f202

device=/dev/ttyUSB0

build: $(chip).hex

clean:
	rm -f *.cod *.hex *.lst

%.hex: %.asm
	gpasm -p $(chip) $+ -o $@

chipinfo:
	picpro chip_info $(chip) | jq

decode_default_fuses:
	picpro decode_fuses 4095 -t $(chip)

proginfo:
	picpro programmer_info -p $(device)

readconfig:
	picpro read_chip_config -p $(device) -t $(chip) --icsp

dump:
	picpro dump rom -p $(device) -t $(chip) -o dump.rom-hex
	picpro dump eeprom -p $(device) -t $(chip) -o dump.eeprom-hex
	picpro dump config -p $(device) -t $(chip) -o dump.config-hex

erase:
	picpro erase -p $(device) -t $(chip) --icsp

hexinfo:
	picpro hex_info $(chip).hex $(chip)

verify:
	picpro verify -p $(device) -i $(chip).hex -t $(chip) --icsp

# BUG:
#   File "/root/venv/lib/python3.13/site-packages/picpro/bin/picpro.py", line 228, in program
#     programming_interface.program_rom(flash_data.rom_data)
#   File "/root/venv/lib/python3.13/site-packages/picpro/protocol/p18a/ProgrammingInterface.py", line 120, in program_rom
#     self.connection.expect(b'P', timeout=20)
#   File "/root/venv/lib/python3.13/site-packages/picpro/protocol/IConnection.py", line 56, in expect
#     raise InvalidResponseError('Expected "{!r}", received {!r}.'.format(expected, response))
# picpro.exceptions.InvalidResponseError: Expected "b'P'", received b'N'.

prog:
	picpro program -p $(device) -i $(chip).hex -t $(chip) --icsp
