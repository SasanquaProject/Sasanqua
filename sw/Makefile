APP := helloworld

all: bootrom app

bootrom:
	make -C bootrom
	# cp bootrom/bootrom.dump .
	cp bootrom/bootrom.mem .

app:
	# cargo objdump --bin $(APP) -- -dSC > $(APP).dump
	cargo objcopy --bin $(APP) -- -O binary $(APP).bin
	od -An -tx4 -w4 -v $(APP).bin > $(APP).mem
	rm -f $(APP).bin

clean:
	rm -rf *.dump *.mem

.PHONY: all bootrom app
