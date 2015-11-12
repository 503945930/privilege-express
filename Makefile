NODE_BIN='./node_modules/.bin'

build:
	$(NODE_BIN)/coffee -o dist -c src/*.coffee

test: build
	$(NODE_BIN)/mocha
	$(NODE_BIN)/istanbul report
