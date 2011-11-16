using Gtk;
using Tracker;
using Gdk;

internal enum AlbumListStoreColumn {
    ALBUM_ART,
    TITLE,
    ID
}

internal class AlbumListStore : ListStore {
    private const string ALBUM_QUERY =
"""

SELECT
    nie:title(?album)
    (SELECT GROUP_CONCAT(nmm:artistName(?artist), ",") WHERE { ?album nmm:albumArtist ?artist })
    tracker:coalesce(nmm:albumTrackCount(?album),
                     (SELECT COUNT(?item) WHERE { ?item nmm:musicAlbum ?album
                                          FILTER(EXISTS { ?item tracker:available "true" }) }))
    tracker:id(?album)
{
    ?album a nmm:MusicAlbum
    FILTER (EXISTS { ?item nmm:musicAlbum ?album; tracker:available "true" })
}
ORDER BY nie:title(?album)
""";

    public AlbumListStore () {
        Object ();

        Type[] types = { typeof (Pixbuf),
                         typeof (string),
                         typeof (uint64) };

        this.set_column_types (types);
        this.fill_list_store.begin ();
    }

    private async void fill_list_store () {
        try {
            var connection = yield Sparql.Connection.get_async ();
            var cursor = yield connection.query_async (ALBUM_QUERY);
            var cache = AlbumArtCache.get_default ();
            while (cursor.next ()) {
                TreeIter iter;
                this.append (out iter);
                this.set (iter,
                          AlbumListStoreColumn.ALBUM_ART,
                              cache.lookup (cursor.get_string (1),
                                            cursor.get_string (0)),
                          AlbumListStoreColumn.TITLE,
                              "%s (%d)".printf (cursor.get_string (0),
                                                (int) cursor.get_integer (2)),
                          AlbumListStoreColumn.ID,
                              cursor.get_integer (3),
                          -1);
            }
        } catch (Error error) {
            critical ("Something bad happened: %s", error.message);
        }
    }
}
