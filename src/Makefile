NULL=

SOURCES=main.vala \
		album-tree-store.vala \
		album-art-cache.vala \
		song-list-store.vala \
		filtered-song-list.vala \
		audio-controls.vala \
		playmate-application.vala \
		multimedia-keys.vala \
		$(NULL)

PACKAGES=--pkg gtk+-3.0 \
		 --pkg gdk-pixbuf-2.0 \
		 --pkg gee-1.0 \
		 --pkg tracker-sparql-0.10 \
		 --pkg gstreamer-0.10 \
		 --pkg libnotify \
		 $(NULL)

VALAFLAGS=--save-temps -g

playmate: $(SOURCES)
	valac $(VALAFLAGS) -o $@ $(SOURCES) $(PACKAGES)
