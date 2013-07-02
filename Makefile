.PHONY: build install uninstall clean

build: dist/setup
	obuild build

dist/setup:
	obuild configure

install:
	obuild install
	ocamlfind install netlink dist/build/lib-netlink/*

uninstall:
	ocamlfind remove netlink

clean:
	obuild clean

