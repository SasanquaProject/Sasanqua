app.mem:
	cargo objdump -- -dSC > app.dump
	cargo objcopy -- -O binary app.bin
	od -An -tx4 -w4 -v app.bin > app.mem
	rm -f app.bin

clean:
	rm -rf *.dump *.mem

.PHONY: app clean
