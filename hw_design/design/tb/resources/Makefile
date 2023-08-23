IMAGE := riscv/devenv

all: riscv-tests

riscv-tests:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash -c "make -C riscv-tests"

bootrom:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash -c "make -C bootrom"
	chown $(shell id -u):$(shell id -u) -R bootrom

devenv:
	docker run --rm -it -v $(shell pwd):/src -w /src $(IMAGE) /bin/bash

.PHONY: riscv-tests bootrom
