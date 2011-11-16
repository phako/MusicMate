using Gtk;

int main (string[] args) {
    Gst.init (ref args);
    Gtk.init (ref args);

    var win = new Window ();
    win.set_size_request (640, 480);
    win.set_default_size (800, 480);

    win.destroy.connect ( () => { Gtk.main_quit (); });

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

    var list_store = new SongListStore ();

    var icon_view = new IconView.with_model (new AlbumListStore ());
    icon_view.show ();
    icon_view.set_pixbuf_column (AlbumListStoreColumn.ALBUM_ART);
    icon_view.set_text_column (AlbumListStoreColumn.TITLE);
    icon_view.set_selection_mode (SelectionMode.MULTIPLE);

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
                debug ("%s", album_id.to_string ());
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
        TreeIter iter;
        var model = list_view.model;

        if (model.get_iter (out iter, path)) {
            string url = null;

            model.get (iter,
                       SongListStoreColumn.URL,
                       ref url,
                       -1);
            controls.uri = url;
        }
    });

    scrolled.add (list_view);

    paned.pack_end (scrolled);

    box.pack_start (paned);

    win.show_all ();
    Gtk.main ();

    return 0;
}
