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

internal class MusicMate.MainWindow : Gtk.ApplicationWindow {
    private SongModelMixer mixer;
    private Notifier notifier;

    public MainWindow (Application app) {
        Object (application: app);
    }

    public override void constructed () {
        base.constructed ();

        var header = new HeaderBar ();
        header.show ();
        header.set_show_close_button (true);
        header.has_subtitle = false;
        this.set_titlebar (header);

        this.notifier = new Notifier ();

        this.set_size_request (640, 480);
        this.set_default_size (800, 480);

        var box = new Box (Orientation.VERTICAL, 6);
        box.margin = 12;
        box.show ();
        this.add (box);

        var stack = new Stack ();
        stack.show ();

        var center = new Box (Orientation.HORIZONTAL, 6);
        var switcher = new StackSwitcher ();
        switcher.show ();
        switcher.set_stack (stack);
        center.set_center_widget (switcher);

        box.pack_start (center, false);
        box.pack_start (stack, true, true);

        var controls = new AudioControls ();
        controls.show ();
        box.pack_end (controls, false);

        var scrolled = new ScrolledWindow (null, null);
        scrolled.show ();

        var list_view = new SongBrowser ();
        var list_store = list_view.model as FilteredSongList;

        this.mixer = new SongModelMixer (list_store);
        controls.bind_property ("shuffle",
                                this.mixer,
                                "shuffle",
                                BindingFlags.DEFAULT |
                                BindingFlags.SYNC_CREATE);

        controls.need_next.connect (this.mixer.get_next);
        controls.need_previous.connect (this.mixer.get_previous);

        var album_view = new AlbumView ();
        album_view.show ();
        album_view.bind_property ("albums",
                                  list_store,
                                  "albums",
                                  BindingFlags.DEFAULT);

        scrolled.add (album_view);
        stack.add_titled (scrolled, "albums", "Albums");

        scrolled = new ScrolledWindow (null, null);
        scrolled.show ();
        stack.add_titled (scrolled, "songs", "Songs");

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

            this.set_title ("%s - %s".printf (artist ?? "Unknown Artist",
                                              title ?? "Unknown Song"));

            if (!this.is_active) {
                this.notifier.update (title, artist, album);
            }
        });

        scrolled.add (list_view);

        this.show_all ();
    }
}
