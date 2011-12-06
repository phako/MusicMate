/*
    This file is part of MusicMate.

    MusicMate is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    MusicMate is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with MusicMate.  If not, see <http://www.gnu.org/licenses/>.
*/

using Gtk;
using Notify;

internal class MusicMate.MainWindow : Gtk.Window {
    private SongModelMixer mixer;
    private Notification notification;

    public MainWindow () {
        Object (type: WindowType.TOPLEVEL);

        this.set_size_request (640, 480);
        this.set_default_size (800, 480);

        var box = new Box (Orientation.VERTICAL, 6);
        box.show ();
        this.add (box);

        var controls = new AudioControls ();
        controls.show ();
        box.pack_end (controls, false);

        var paned = new Box(Orientation.HORIZONTAL, 6);
        paned.show ();

        var scrolled = new ScrolledWindow (null, null);
        scrolled.show ();

        var list_view = new SongBrowser ();
        var list_store = list_view.model as FilteredSongList;

        this.mixer = new SongModelMixer (list_store);
        controls.bind_property ("shuffle",
                                this.mixer,
                                "shuffle",
                                BindingFlags.DEFAULT);

        controls.need_next.connect (this.mixer.get_next);
        controls.need_previous.connect (this.mixer.get_previous);

        var album_view = new AlbumView ();
        album_view.show ();
        album_view.bind_property ("albums",
                                  list_store,
                                  "albums",
                                  BindingFlags.DEFAULT);

        scrolled.add (album_view);
        scrolled.set_size_request (300, -1);
        paned.pack_start (scrolled, false);

        scrolled = new ScrolledWindow (null, null);
        scrolled.show ();

        list_view.show ();
        list_view.row_activated.connect ( (path) => {
            controls.uri = this.mixer.set_current (path);
        });

        this.mixer.current.connect ( (path) => {
            list_view.set_cursor (path, null, false);
            TreeIter iter;
            list_store.get_iter (out iter, path);
            uint duration;
            string album;
            string artist;
            string title;

            list_store.get (iter,
                            SongListStoreColumn.DURATION,
                                out duration,
                            SongListStoreColumn.ALBUM,
                                out album,
                            SongListStoreColumn.ARTIST,
                                out artist,
                            SongListStoreColumn.TITLE,
                                out title
                            );
            controls.set_duration (duration);

            this.update_notification (title, artist, album);

            this.set_title ("%s - %s".printf (artist ?? "Unknown Artist",
                                              title ?? "Unknown Song"));
        });

        scrolled.add (list_view);

        paned.pack_end (scrolled);

        box.pack_start (paned);

        this.show_all ();

    }

    private void update_notification (string? title,
                                      string? artist,
                                      string? album) {

        if (this.is_active) {
            return;
        }

        var text = "";
        if (title != null) {
            text = "<i>%s</i>".printf (Markup.escape_text
                                        (title ?? "Unknown Title"));
        }

        if (artist != null) {
            text += " by <i>%s</i>".printf (Markup.escape_text (artist));
        }

        if (album != null) {
            text += " from <i>%s</i>".printf (Markup.escape_text (album));
        }

        try {
            if (unlikely (this.notification == null)) {
                this.notification = new Notification (" ", text, null);
            } else {
                string? empty = null;
                this.notification.update (" ", text, empty);
            }

            var cache = AlbumArtCache.get_default ();
            notification.set_image_from_pixbuf (cache.lookup (artist,
                                                              album));
            notification.show ();
        } catch (Error error) {
            warning ("Failed to show notification: %s", error.message);
        }
    }

}
