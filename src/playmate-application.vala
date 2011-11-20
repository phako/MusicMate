using Gtk;
using Notify;

internal class Playmate.Application : Gtk.Application {
    public const string APPNAME = "org.jensge.PlayMate";

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

        var list_store = new FilteredSongList ();
        list_store.shuffle = true;
        controls.need_next.connect (list_store.get_next);
        controls.need_previous.connect (list_store.get_previous);

        var icon_view = new IconView.with_model (new AlbumListStore ());
        icon_view.show ();
        icon_view.set_pixbuf_column (AlbumListStoreColumn.ALBUM_ART);
        icon_view.set_text_column (AlbumListStoreColumn.TITLE);
        icon_view.set_selection_mode (SelectionMode.MULTIPLE);
        icon_view.set_columns (2);
        icon_view.set_item_width (115);

        icon_view.selection_changed.connect (() => {
            var albums = new string[0];
            var items = icon_view.get_selected_items ();
            var model = icon_view.get_model ();
            foreach (var item in items) {
                TreeIter iter;
                if (model.get_iter (out iter, item)) {
                    uint64 album_id = 0;
                    model.get (iter,
                               AlbumListStoreColumn.ID,
                               ref album_id,
                               -1);
                    albums += album_id.to_string ();
                }
            }

            list_store.albums = string.joinv (",", albums);
        });

        scrolled.add (icon_view);
        scrolled.set_size_request (300, -1);
        paned.pack_start (scrolled, false);

        scrolled = new ScrolledWindow (null, null);
        scrolled.show ();

        var list_view = new TreeView.with_model (list_store);
        list_view.show ();
        list_view.insert_column_with_attributes (-1,
                                                 "Disc",
                                                 new CellRendererText (),
                                                 "text",
                                                 SongListStoreColumn.DISC);

        list_view.insert_column_with_attributes (-1,
                                                 "Track",
                                                 new CellRendererText (),
                                                 "text",
                                                 SongListStoreColumn.TRACK);

        list_view.insert_column_with_attributes (-1,
                                                 "Title",
                                                 new CellRendererText (),
                                                 "text",
                                                 SongListStoreColumn.TITLE);

        list_view.insert_column_with_attributes (-1,
                                                 "Album",
                                                 new CellRendererText (),
                                                 "text",
                                                 SongListStoreColumn.ALBUM);

        list_view.row_activated.connect ( (path) => {
            controls.uri = list_store.set_current (path);
        });

        list_store.current.connect ( (path) => {
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
