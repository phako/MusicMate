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

internal class MusicMate.SongModelMixer : Object {
    private int next_song;
    private TreeModel model;
    private uint grace_timer;
    private int[] shuffle_list;

    public bool shuffle { get; set; }

    public signal void current (TreePath path);

    public SongModelMixer (TreeModel model) {
        this.next_song = -1;
        this.model = model;
        this.grace_timer = 0;
        model.row_deleted.connect (this.on_model_row_modified);
        model.row_inserted.connect (this.on_model_row_modified);
        this.notify["shuffle"].connect ( () => {
            this.generate_shuffle_list ();
        });
    }

    private string? get_current () {
        var index = this.shuffle_list[this.next_song];

        var path = new TreePath.from_indices (index);
        TreeIter iter;
        string url;

        this.model.get_iter (out iter, path);
        this.model.get (iter, SongListStoreColumn.URL, out url);

        this.current (path);

        return url;
    }

    public string? set_current (TreePath path) {
        var index = path.get_indices ()[0];
        if (this.shuffle) {
            for (var i = 0; i < this.shuffle_list.length; i++) {
                if (this.shuffle_list[i] == index) {
                    this.next_song = i;

                    break;
                }
            }
        } else {
            this.next_song = index;
        }

        return this.get_current ();
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

    private void on_model_row_modified () {
        if (this.grace_timer != 0) {
            Source.remove (this.grace_timer);
        }

        this.grace_timer = Timeout.add (100, this.on_update_settled);
    }

    private bool on_update_settled () {
        this.generate_shuffle_list ();
        this.grace_timer = 0;

        return false;
    }

    private void generate_shuffle_list () {
        var rows = this.model.iter_n_children (null);
        if (rows == 0) {
            return;
        }

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
