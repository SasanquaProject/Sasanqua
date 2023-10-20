COPGEN_BIN := ./target/release/copgen_cui

build:
	cargo build --release

new:
	$(COPGEN_BIN) new -o cop.toml

gen:
	$(COPGEN_BIN) gen cop.toml -o cop_ip

shell:
	$(COPGEN_BIN) interactive

clean:
	rm -rf cop.toml cop_ip

.PHONY: build clean new gen clean
