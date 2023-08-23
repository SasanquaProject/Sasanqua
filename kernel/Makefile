all: bootrom.mem

bootrom.mem:
	make -C bootrom
	cp bootrom/bootrom.mem .

clean:
	make -C bootrom clean
	rm bootrom.mem

.PHONY: all bootrom.mem clean

