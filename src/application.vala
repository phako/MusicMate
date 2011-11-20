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

internal class MusicMate.Application : Gtk.Application {
    private SongModelMixer mixer;
    public const string APPNAME = "org.jensge.MusicMate";

    public Application () {
        Object (application_id : APPNAME,
                flags: ApplicationFlags.FLAGS_NONE);
    }

    public override void activate () {
        unowned List<weak Window> windows = this.get_windows ();
        if (windows != null) {
            windows.data.present ();

            return;
        }

        var win = new Window ();
        this.add_window (win);
        win.set_size_request (640, 480);
        win.set_default_size (800, 480);

        var box = new Box (Orientation.VERTICAL, 6);
        box.show ();
        win.add (box);

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
        this.mixer.shuffle = true;
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
            controls.set_meta_data (duration, artist, album, title);

            if (! win.is_active) {
                var text = "";
                if (title != null) {
                    text = "<i>%s</i>".printf (Markup.escape_text (title));
                } else {
                    text = "<i>Unkown song</i>";
                }

                if (artist != null) {
                    text += " by <i>%s</i>".printf (Markup.escape_text (artist));
                }

                if (album != null) {
                    text += " from <i>%s</i>".printf (Markup.escape_text (album));
                }

                try {
                    var notification = new Notification ("New Song", text, null);
                    var cache = AlbumArtCache.get_default ();
                    notification.set_image_from_pixbuf (cache.lookup (artist,
                                                                      album));
                    notification.show ();
                } catch (Error error) {
                    warning ("Failed to show notification: %s", error.message);
                }
            }
        });

        scrolled.add (list_view);

        paned.pack_end (scrolled);

        box.pack_start (paned);

        win.show_all ();
    }
}
