ifneq "$(DESTDIR)" ""
INSTALL_ARGS := -destdir $(DESTDIR)
endif

.PHONY: build install uninstall clean

build: dist/setup
	obuild build

dist/setup:
	obuild configure

install:
	ocamlfind remove netlink $(INSTALL_ARGS)
	ocamlfind install netlink lib/META dist/build/lib-netlink/* $(INSTALL_ARGS)

uninstall:
	ocamlfind remove netlink

clean:
	obuild clean

