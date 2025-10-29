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

# BUG:
#   File "/root/venv/lib/python3.13/site-packages/picpro/FlashData.py", line 99, in _calculate_rom_blank_word
# blank_word = 0xffff << self.chip_info.core_bits
#    raise ValueError('Failed to detect core bits.')

hexinfo:
	picpro hex_info $(chip).hex $(chip)

prog:
	picpro program -p $(device) -i $(chip).hex -t $(chip) --icsp

verify:
	picpro verify -p $(device) -i $(chip).hex -t $(chip) --icsp
