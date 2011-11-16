using Gtk;
using Tracker;

internal enum SongListStoreColumn {
    DISC = 0,
    TRACK,
    ALBUM,
    TITLE,
    URL
}

internal class SongListStore : ListStore {
    private const string QUERY_TEMPLATE =
"""
SELECT
        nie:title(nmm:musicAlbum(?song))
        nmm:setNumber(nmm:musicAlbumDisc(?song))
        nmm:trackNumber(?song)
        nie:title(?song)
        nie:url(?song)
{
        ?song a nmm:MusicPiece
        %s
}

ORDER BY
        nie:title(nmm:musicAlbum(?song))
        nmm:setNumber(nmm:musicAlbumDisc(?song))
        nmm:trackNumber(?song)
        nie:title(?song)
""";

    public string albums { get; set; }
    public SongListStore () {
        Object ();

        Type[] types = { typeof (uint),
                         typeof (uint),
                         typeof (string),
                         typeof (string),
                         typeof (string)};
        this.set_column_types (types);
        this.fill_list_store.begin ();
        this.notify["albums"].connect ( (s, p) => {
            this.fill_list_store.begin ();
        });
    }

    private async void fill_list_store () {
        try {
            this.clear ();
            var connection = yield Sparql.Connection.get_async ();
            var cursor = yield connection.query_async (this.get_query ());
            while (cursor.next ()) {
                TreeIter iter;
                this.append (out iter);
                this.set (iter,
                          SongListStoreColumn.DISC,
                              (uint) cursor.get_integer (1),
                          SongListStoreColumn.TRACK,
                              (uint) cursor.get_integer (2),
                          SongListStoreColumn.ALBUM,
                              cursor.get_string (0),
                          SongListStoreColumn.TITLE,
                              cursor.get_string (3),
                          SongListStoreColumn.URL,
                              cursor.get_string (4));
            }
        } catch (Error error) {
            critical ("Something failed: %s", error.message);
        }
    }

    private string get_query () {
        var filter = "";
        if (this.albums != null && this.albums.length > 0) {
            filter += "FILTER(tracker:id(nmm:musicAlbum(?song)) IN (";
            filter += this.albums;
            filter += "))";
        }

        debug ("%s", QUERY_TEMPLATE.printf (filter));

        return QUERY_TEMPLATE.printf (filter);
    }
}
