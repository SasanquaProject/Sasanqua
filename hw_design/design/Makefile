COREGEN_WORKDIR := cd core &&
COPGEN_WORKDIR := cd cop &&

COREGEN_BIN := ./bin/coregen_cui
COPGEN_BIN := ./bin/copgen_cui

# General
build:
	mkdir -p bin
	$(COREGEN_WORKDIR) cargo build --release && cp target/release/coregen_cui $(shell pwd)/bin
	$(COPGEN_WORKDIR)  cargo build --release && cp target/release/copgen_cui $(shell pwd)/bin

clean:
	make core.clean
	make cop.clean
	rm -rf bin

# Core
core.new:
	$(COREGEN_BIN) new -o core.toml

core.gen:
	$(COREGEN_BIN) gen core.toml -o core_ip

core.shell:
	$(COREGEN_BIN) interactive

core.clean:
	rm -rf core.toml core_ip

# Cop
cop.new:
	$(COPGEN_BIN) new -o cop.toml

cop.gen:
	$(COPGEN_BIN) gen cop.toml -o cop_ip

cop.shell:
	$(COPGEN_BIN) interactive

cop.clean:
	rm -rf cop.toml cop_ip

.PHONY: build clean core.new core.gen core.clean cop.new cop.gen cop.clean
