PHONY: build

all: build

chip=10f202

device=/dev/ttyUSB0

build: blink.hex

clean:
	rm -f *.cod *.hex *.lst

%.hex: %.asm
	gpasm -p $(chip) $+ -o $@

chipinfo:
	picpro chipinfo $(chip) | jq

hexinfo:
	picpro hexinfo *.hex $(chip)

dumpconfig:
	picpro dump config -p $(device) -t $(chip) -o dump.hex 
