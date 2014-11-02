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
using Tracker;

internal enum MusicMate.SongListStoreColumn {
    DISC = 0,
    TRACK,
    ALBUM,
    TITLE,
    URL,
    ALUBUM_ID,
    DURATION,
    ARTIST
}

internal class MusicMate.SongListStore : ListStore {
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
        FILTER(fn:starts-with(nie:url(?song), '%s'))
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
            unowned string music_dir = Environment.get_user_special_dir
                                        (UserDirectory.MUSIC);
            var uri = File.new_for_path (music_dir).get_uri ();
            var query = QUERY.printf (uri);
            var cursor = yield connection.query_async (query);
            debug ("Running SPARQL query %s", query);
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
