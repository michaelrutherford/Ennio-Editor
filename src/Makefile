all:
	valac *.vala --pkg gtk+-3.0 --pkg gtksourceview-3.0 -o ennio

clean:
	rm -rf *.o app1

install:
	cp -f ennio /usr/bin

uninstall:
	rm -f /usr/bin/ennio
