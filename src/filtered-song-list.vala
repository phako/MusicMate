using Gee;
using Gtk;

internal class FilteredSongList : TreeModelFilter {
    private HashSet<string> album_list;
    public string albums { get; set; }

    public FilteredSongList () {
        Object (child_model : new SongListStore (),
                virtual_root : null );

        this.notify["albums"].connect ( () => {
            this.album_list.clear ();
            foreach (var album in this.albums.split (",")) {
                this.album_list.add (album);
            }

            this.refilter ();
        });

        this.album_list = new HashSet<string> ();

        this.set_visible_func (this.filter_albums);
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
}
