desktopdir=$(datadir)/applications
desktop_DATA=data/MusicMate.desktop

icondir=$(datadir)/MusicMate/icons
icon_DATA=data/album-default.png data/album-default.svg

EXTRA_DIST=data
bin_PROGRAMS=musicmate

ACLOCAL_AMFLAGS = -I m4 ${ACLOCAL_FLAGS}

gsettings_SCHEMAS = data/org.jensge.MusicMate.gschema.xml
@GSETTINGS_RULES@

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
				  src/main-window.vala \
				  notifier.vala

PACKAGES=--pkg gtk+-3.0 \
		 --pkg gdk-pixbuf-2.0 \
		 --pkg gee-0.8 \
		 --pkg tracker-sparql-1.0 \
		 --pkg gstreamer-1.0 \
		 --pkg libnotify

musicmate_VALAFLAGS=$(PACKAGES) \
					-g --enable-experimental

musicmate_CFLAGS=\
				 $(GTK_CFLAGS) \
				 $(GDK_PIXBUF_CFLAGS) \
				 $(GEE_CFLAGS) \
				 $(TRACKER_CFLAGS) \
				 $(GSTREAMER_CFLAGS) \
				 $(NOTIFY_CFLAGS) \
				 -DICON_DIR='"$(icondir)"'

musicmate_LDADD=\
				 $(GTK_LIBS) \
				 $(GDK_PIXBUF_LIBS) \
				 $(GEE_LIBS) \
				 $(TRACKER_LIBS) \
				 $(GSTREAMER_LIBS) \
				 $(NOTIFY_LIBS)


