COREGEN_BIN := ./target/release/coregen_cui

build:
	cargo build --release

new:
	$(COREGEN_BIN) new -o core.toml

gen:
	$(COREGEN_BIN) gen core.toml -o core_ip

shell:
	$(COREGEN_BIN) interactive

clean:
	rm -rf core.toml core_ip

.PHONY: build clean new gen clean
