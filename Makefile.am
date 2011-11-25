bin_PROGRAMS=musicmate

NULL=

musicmate_SOURCES=src/main.vala \
				  src/album-art-cache.vala \
				  src/album-list-store.vala \
				  src/album-view.vala \
				  src/song-list-store.vala \
				  src/song-browser.vala \
				  src/song-model-mixer.vala \
				  src/filtered-song-list.vala \
				  src/audio-controls.vala \
				  src/application.vala \
				  src/media-keys.vala \
				  $(NULL)

PACKAGES=--pkg gtk+-3.0 \
		 --pkg gdk-pixbuf-2.0 \
		 --pkg gee-1.0 \
		 --pkg tracker-sparql-0.10 \
		 --pkg gstreamer-0.10 \
		 --pkg libnotify \
		 $(NULL)

musicmate_VALAFLAGS=$(PACKAGES) \
					-g
					$(NULL)

musicmate_CFLAGS=\
				 $(GTK_CFLAGS) \
				 $(GDK_PIXBUF_CFLAGS) \
				 $(GEE_CFLAGS) \
				 $(TRACKER_CFLAGS) \
				 $(GSTREAMER_CFLAGS) \
				 $(NOTIFY_CFLAGS) \
				 $(NULL)

musicmate_LDADD=\
				 $(GTK_LIBS) \
				 $(GDK_PIXBUF_LIBS) \
				 $(GEE_LIBS) \
				 $(TRACKER_LIBS) \
				 $(GSTREAMER_LIBS) \
				 $(NOTIFY_LIBS) \
				 $(NULL)

desktopdir=${datadir}/applications
desktop_DATA=data/MusicMate.desktop
EXTRA_DIST=data
