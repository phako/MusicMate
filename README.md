# MusicMate

MusicMate is a simple audio player using the [tracker project](https://wiki.gnome.org/Projects/Tracker) as its meta-data
source.

To build from git, run:

```sh
$ meson build
$ ninja -C build
```

and to run from inside the build directory, run:

```sh
$ ninja -C build data/gschemas.compiled
$ GSETTINGS_SCHEMA_DIR=build/data build/src/musicmate
```