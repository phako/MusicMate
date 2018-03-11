AC_PREREQ([2.64])
AC_INIT([MusicMate],
        [0.1])

AC_CONFIG_AUX_DIR([build-aux])

AC_CONFIG_SRCDIR([src/main.vala])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

AC_PROG_CC
AM_PROG_CC_C_O

dnl Initialize automake
AM_INIT_AUTOMAKE([1.11.1 tar-ustar no-dist-gzip dist-xz subdir-objects])
AM_MAINTAINER_MODE([enable])
AM_SILENT_RULES([yes])

GLIB_GSETTINGS

PKG_CHECK_MODULES(GTK, gtk+-3.0 >= 3.2)
PKG_CHECK_MODULES(GDK_PIXBUF, gdk-pixbuf-2.0)
PKG_CHECK_MODULES(GEE, gee-0.8)
PKG_CHECK_MODULES(TRACKER, tracker-sparql-2.0)
PKG_CHECK_MODULES(GSTREAMER, gstreamer-1.0)
PKG_CHECK_MODULES(NOTIFY, libnotify)

AC_ARG_ENABLE([vala],
              [AS_HELP_STRING([--enable-vala],
                              [enable building from vala sources])],,
              [enable_vala=no])

AS_IF([test "x$enable_vala" = xyes],
      [
       AM_PROG_VALAC([0.14])

       if [test "x$VALAC" = "x"]
       then
           AC_MSG_ERROR([Cannot find the "valac" compiler in your PATH])
       else
           VALA_CHECK_PACKAGES([gtk+-3.0 gdk-pixbuf-2.0 gee-0.8])
           VALA_CHECK_PACKAGES([tracker-sparql-2.0 gstreamer-1.0])
           VALA_CHECK_PACKAGES([libnotify])
       fi
      ],
      []
)

AC_CONFIG_FILES([
Makefile
])

AC_OUTPUT
