include config.mk

.PHONY: all install uninstall filter clean test dist

all: commode
clean:
	rm -f commode *.o *.core sl_test filter/indent

install: commode
	cp commode $(DESTDIR)$(BINDIR)
#	cp commode.1 $(DESTDIR)$(MAN1DIR)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/commode $(DESTDIR)$(MAN1DIR)/commode.1

test: sl_test
	./sl_test

dist:
	mkdir -p commode-$(VERSION)
	cp -r $$(git ls-tree --name-only HEAD) commode-$(VERSION)
	tar -czf commode-$(VERSION).tar.gz commode-$(VERSION)
	rm -fr commode-$(VERSION)

commode: commode.o slackline.o util.o slackline_emacs.o
	$(CC) -o $@ commode.o slackline.o slackline_emacs.o util.o $(LIBS)

commode.o: commode.c
	$(CC) -c $(CFLAGS) -D_BSD_SOURCE -D_XOPEN_SOURCE -D_GNU_SOURCE \
	    -o $@ commode.c

filter: filter/indent
filter/indent: filter/indent.c util.o util.h
	$(CC) $(CFLAGS) -o $@ filter/indent.c util.o

sl_test.o: sl_test.c slackline.h
	$(CC) $(CFLAGS) -Wno-sign-compare -c -o $@ sl_test.c

sl_test: sl_test.o slackline.o slackline_emacs.o slackline.h
	$(CC) $(CFLAGS) -o $@ sl_test.o slackline.o slackline_emacs.o $(LIBS)

slackline.o: slackline.c slackline.h
	$(CC) -c $(CFLAGS) -o $@ slackline.c

slackline_emacs.o: slackline_emacs.c slackline.h
	$(CC) -c $(CFLAGS) -o $@ slackline_emacs.c

util.o: util.c util.h
	$(CC) -c $(CFLAGS) -D_BSD_SOURCE -o $@ util.c
