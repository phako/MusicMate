NULL=

SOURCES=main.vala \
		album-art-cache.vala \
		album-list-store.vala \
		album-view.vala \
		song-list-store.vala \
		song-browser.vala \
		song-model-mixer.vala \
		filtered-song-list.vala \
		audio-controls.vala \
		application.vala \
		media-keys.vala \
		$(NULL)

PACKAGES=--pkg gtk+-3.0 \
		 --pkg gdk-pixbuf-2.0 \
		 --pkg gee-1.0 \
		 --pkg tracker-sparql-0.10 \
		 --pkg gstreamer-0.10 \
		 --pkg libnotify \
		 $(NULL)

VALAFLAGS=--save-temps -g

musicmate: $(SOURCES)
	valac $(VALAFLAGS) -o $@ $(SOURCES) $(PACKAGES)

clean:
	rm -f *.c
	rm -f musicmate
	rm -f core
	rm -f massif.out.*
	rm -f valgrind.log.*
