project('MusicMate', ['vala', 'c'],
        version : '0.1')

gnome = import('gnome')

gtk = dependency('gtk+-3.0', version : '>= 3.2')
gdk_pixbuf = dependency('gdk-pixbuf-2.0')
gee = dependency('gee-0.8')
gstreamer = dependency('gstreamer-1.0')
notify = dependency('libnotify')
tracker = dependency('tracker-sparql-2.0')

resources = gnome.compile_resources('musicmate-resources', 'data/org.jensge.MusicMate.gresource.xml')

subdir('data')
subdir('src')
