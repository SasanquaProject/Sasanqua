all: bootrom.mem app.mem
	cp bootrom/bootrom.mem .
	cp aaa/app.mem .

bootrom.mem:
	make -C bootrom

app.mem:
	make -C app

clean:
	make -C bootrom clean

.PHONY: clean

