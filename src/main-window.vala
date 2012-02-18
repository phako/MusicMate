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

internal class MusicMate.Switcher : ButtonBox {
    public Switcher (Notebook notebook) {
        Object (layout_style: ButtonBoxStyle.CENTER);
        var album_button = new RadioButton.with_label (null, "Albums");
        album_button.set_mode (false);
        album_button.set_alignment (0.5f, 0.5f);
        this.pack_start (album_button, false, false, 0);
        album_button.show ();
        album_button.toggled.connect ( () => {
            if (album_button.active) {
                notebook.set_current_page (0);
            }
        });

        var song_button = new RadioButton.with_label_from_widget (album_button,
                                                                  "Songs");
        song_button.set_mode (false);
        song_button.set_alignment (0.5f, 0.5f);
        this.pack_start (song_button, false, false, 0);
        song_button.show ();
        song_button.toggled.connect ( () => {
            if (song_button.active) {
                notebook.set_current_page (1);
            }
        });
    }
}

internal class MusicMate.MainWindow : Gtk.Window {
    private SongModelMixer mixer;
    private Notifier notifier;

    public MainWindow () {
        Object (type: WindowType.TOPLEVEL);

        this.notifier = new Notifier ();

        this.set_size_request (640, 480);
        this.set_default_size (800, 480);

        var box = new Box (Orientation.VERTICAL, 6);
        box.margin = 12;
        box.show ();
        this.add (box);


        var notebook = new Notebook ();
        notebook.show_tabs = false;

        var switcher = new Switcher (notebook);
        switcher.show ();

        box.pack_start (switcher, false);
        box.pack_start (notebook, true, true);

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
        notebook.append_page (scrolled);

        scrolled = new ScrolledWindow (null, null);
        scrolled.show ();
        notebook.append_page (scrolled);

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
