MAKEFLAGS = -j1

export NODE_ENV = test

.PHONY: build watch lint fix clean test-clean test-only test test-ci publish bootstrap

build: clean
	./node_modules/.bin/gulp build

watch: clean
	rm -rf packages/*/lib
	./node_modules/.bin/gulp watch

lint:
	./node_modules/.bin/eslint packages/ --format=codeframe

fix:
	./node_modules/.bin/eslint packages/ --format=codeframe --fix

clean: test-clean
	rm -rf coverage
	rm -rf packages/*/npm-debug*

test-clean:
	rm -rf packages/*/test/tmp
	rm -rf packages/*/test-fixtures.json

clean-all:
	rm -rf node_modules
	rm -rf packages/*/node_modules
	make clean

test-only:
	./scripts/test.sh
	make test-clean

test: lint test-only

test-ci:
	make bootstrap
	make test-only

publish:
	git pull --rebase
	rm -rf packages/*/lib
	BABEL_ENV=production make build
	make test
	./node_modules/.bin/lerna publish
	make clean

bootstrap:
	make clean-all
	yarn
	./node_modules/.bin/lerna bootstrap
	make build
