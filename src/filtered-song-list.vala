using Gee;
using Gtk;

internal class FilteredSongList : TreeModelFilter {
    private HashSet<string> album_list;
    private int[] shuffle_list;
    private int next_song;

    public string albums { get; set; }
    public bool shuffle { get; set; }

    public signal void current (TreePath path);

    public FilteredSongList () {
        var model = new SongListStore ();
        Object (child_model : model,
                virtual_root : null );

        this.notify["albums"].connect (this.update_filter);

        this.album_list = new HashSet<string> ();
        this.set_visible_func (this.filter_albums);

        model.finished.connect ( () => {
            this.generate_shuffle_list ();
        });
    }

    private void update_filter () {
        this.album_list.clear ();
        foreach (var album in this.albums.split (",")) {
            this.album_list.add (album);
        }

        this.refilter ();
        this.generate_shuffle_list ();
    }

    private bool filter_albums (TreeModel model, TreeIter iter) {
        string tracker_id = null;

        if (this.album_list.is_empty) {
            return true;
        }

        model.get (iter,
                   SongListStoreColumn.ALUBUM_ID,
                   ref tracker_id);

        if (tracker_id == null) {
            return false;
        }

        return album_list.contains (tracker_id);
    }

    private string? get_current () {
        var index = this.shuffle_list[this.next_song];

        var path = new TreePath.from_indices (index);
        TreeIter iter;
        string url;

        this.get_iter (out iter, path);
        this.get (iter,
                  SongListStoreColumn.URL,
                      out url);

        this.current (path);

        return url;
    }

    public string? get_next () {
        var next = this.get_current ();
        this.next_song = (this.next_song + 1) % this.shuffle_list.length;
        return next;
    }

    public string? get_previous () {
        this.next_song = (this.next_song -1 ) % this.shuffle_list.length;
        return this.get_current ();
    }

    private void generate_shuffle_list () {
        var rows = this.iter_n_children (null);
        this.shuffle_list = new int[rows];
        this.shuffle_list[0] = 0;

        for (int i = 1; i < rows; i++) {
            if (this.shuffle) {
                var j = Random.int_range (0, i);
                this.shuffle_list[i] = this.shuffle_list[j];
                this.shuffle_list[j] = i;
            } else {
                this.shuffle_list[i] = i;
            }
        }

        this.next_song = 0;
    }
}
