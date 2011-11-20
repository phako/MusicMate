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

internal class MusicMate.AlbumView : IconView {
    public string albums { get; private set; }
    public AlbumView () {
        Object (model: new AlbumListStore ());

        this.set_pixbuf_column (AlbumListStoreColumn.ALBUM_ART);
        this.set_text_column (AlbumListStoreColumn.TITLE);
        this.set_selection_mode (SelectionMode.MULTIPLE);
        this.set_columns (2);
        this.set_item_width (115);

        this.selection_changed.connect (this.on_selection_changed);
    }

    private void on_selection_changed () {
        var albums = new string[0];
        var items = this.get_selected_items ();
        var model = this.get_model ();
        foreach (var item in items) {
            TreeIter iter;
            if (model.get_iter (out iter, item)) {
                uint64 album_id = 0;
                model.get (iter,
                           AlbumListStoreColumn.ID,
                               ref album_id);
                albums += album_id.to_string ();
            }
        }

        this.albums = string.joinv (",", albums);
    }
}
