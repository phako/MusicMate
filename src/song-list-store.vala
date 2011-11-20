using Gtk;
using Tracker;

internal enum SongListStoreColumn {
    DISC = 0,
    TRACK,
    ALBUM,
    TITLE,
    URL,
    ALUBUM_ID,
    DURATION,
    ARTIST
}

internal class SongListStore : ListStore {
    private const string QUERY =
"""
SELECT
        nie:title(nmm:musicAlbum(?song))
        nmm:setNumber(nmm:musicAlbumDisc(?song))
        nmm:trackNumber(?song)
        nie:title(?song)
        nie:url(?song)
        tracker:id(nmm:musicAlbum(?song))
        nfo:duration(?song)
        nmm:artistName(nmm:performer(?song))
{
        ?song a nmm:MusicPiece
}

ORDER BY
        nie:title(nmm:musicAlbum(?song))
        nmm:setNumber(nmm:musicAlbumDisc(?song))
        nmm:trackNumber(?song)
        nie:title(?song)
""";

    public signal void finished ();

    public SongListStore () {
        Object ();

        Type[] types = { typeof (uint),
                         typeof (uint),
                         typeof (string),
                         typeof (string),
                         typeof (string),
                         typeof (string),
                         typeof (uint),
                         typeof (string),
                         typeof (string)};
        this.set_column_types (types);
        this.fill_list_store.begin ();
    }

    private async void fill_list_store () {
        try {
            this.clear ();
            var connection = yield Sparql.Connection.get_async ();
            var cursor = yield connection.query_async (QUERY);
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
                              cursor.get_string (4),
                          SongListStoreColumn.ALUBUM_ID,
                              cursor.get_string (5),
                          SongListStoreColumn.DURATION,
                              (uint) cursor.get_integer (6),
                          SongListStoreColumn.ARTIST,
                              cursor.get_string (7));
            }
        } catch (Error error) {
            critical ("Something failed: %s", error.message);
        }

        this.finished ();
    }
}
