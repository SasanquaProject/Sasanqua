SRCS :=\
	$(wildcard src/pages/*.tsx) \
	src/style.css \
	package.json \
	next.config.js

run: node_modules
	npm run dev

build: node_modules $(SRCS)
	npm run build

node_modules:
	npm install

.PHONY: run
