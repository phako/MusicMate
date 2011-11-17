using Gee;
using Gdk;

internal class AlbumArtCache : Object {
    private static AlbumArtCache instance;
    private const string invalid_chars = "()[]<>{}_!@#$^&*+=|\\/\"'?~";
    private const string convert_chars = "\t";
    private const string block_pattern = "%s[^%s]*%s";
    private const string[] blocks = { "()", "{}", "[]", "<>" };
    private Regex char_remove_regex;
    private Regex char_convert_regex;
    private Regex space_compress_regex;
    private Regex[] block_regexes;
    private string cache_dir;

    public static AlbumArtCache get_default () {
        if (unlikely (instance == null)) {
            instance = new AlbumArtCache ();
        }

        return instance;
    }

    private AlbumArtCache () {
        try {
            var regex_string = Regex.escape_string (invalid_chars);
            char_remove_regex = new Regex ("[%s]".printf (regex_string));
            regex_string = Regex.escape_string (convert_chars);
            char_convert_regex = new Regex ("[%s]".printf (regex_string));
            space_compress_regex = new Regex ("\\s+");
            block_regexes = new Regex[0];

            foreach (var block in blocks) {
                var block_re = block_pattern.printf (
                                  Regex.escape_string ("%C".printf (block[0])),
                                  Regex.escape_string ("%C".printf (block[1])),
                                  Regex.escape_string ("%C".printf (block[1])));
                block_regexes += new Regex (block_re);
            }
        } catch (RegexError error) {
            assert_not_reached ();
        }

        this.cache_dir = Path.build_filename (Environment.get_user_cache_dir (),
                                              "media-art");
    }

    public Pixbuf? lookup (string? artist_, string ?album_) {
        var artist = artist_;
        var album = album_;

        if (artist == null) {
            artist = " " ;
        }

        if (album == null) {
            album = " ";
        }

        try {
            var key = "album-%s-%s".printf (
                normalize_and_hash (artist),
                normalize_and_hash (album));
            var path = Path.build_filename (this.cache_dir, key + ".jpeg");
            return new Pixbuf.from_file_at_scale (path,
                                                  96,
                                                  96,
                                                  true);
        } catch (Error error) { }

        try {
            var key = "album-%s-%s".printf (
                normalize_and_hash (artist, false, true),
                normalize_and_hash (album, false, true));
            var path = Path.build_filename (this.cache_dir, key + ".jpeg");
            return new Pixbuf.from_file_at_scale (path,
                                                  96,
                                                  96,
                                                  true);
        } catch (Error error) { }

        try {
            var key = "album-%s-%s".printf (
                normalize_and_hash (" ", false, true),
                normalize_and_hash (album, false, true));
            var path = Path.build_filename (this.cache_dir, key + ".jpeg");
            return new Pixbuf.from_file_at_scale (path,
                                                  96,
                                                  96,
                                                  true);
        } catch (Error error) { }

        /*
        try {
            var simple_key = "album-%s".printf (
                normalize_and_hash (artist + "\t" + album, true, true));
            var path = Path.build_filename (this.cache_dir, simple_key + ".jpg");
            return new Pixbuf.from_file_at_scale (path,
                                                  96,
                                                  96,
                                                  true);
        } catch (Error error) { }
*/
        try {
            var simple_key = "album-%s".printf (
                normalize_and_hash (artist + "\t" + album, true, true));
            var path = Path.build_filename (this.cache_dir, "90", simple_key + ".jpg");
            debug ("Checking path %s for album %s", path, album);
            return new Pixbuf.from_file_at_scale (path,
                                                  96,
                                                  96,
                                                  true);
        } catch (Error error) { }

/*        try {
            var simple_key = "album-%s".printf (
                normalize_and_hash (artist + "\t" + album, true));
            var path = Path.build_filename (this.cache_dir, "90", simple_key + ".jpg");
            return new Pixbuf.from_file_at_scale (path,
                                                  96,
                                                  96,
                                                  true);
        } catch (Error error) { }


        try {
            var simple_key = "album-%s".printf (
                normalize_and_hash (artist + "\t" + album, true));
            var path = Path.build_filename (this.cache_dir, simple_key + ".jpg");
            return new Pixbuf.from_file_at_scale (path,
                                                  96,
                                                  96,
                                                  true);
        } catch (Error error) { }
*/
        return null;
    }

    private string normalize_and_hash (string? input,
                                       bool utf8_only = false,
                                       bool utf8 = false) {
        string normalized = " ";
        if (input != null && input != "") {
            if (utf8_only) {
                normalized = input;
            } else {
                normalized = this.strip_invalid_entities (input);
                normalized = normalized.down ();
            }

            if (utf8) {
                normalized = normalized.normalize (-1, NormalizeMode.NFKD);
            }
        }

        return Checksum.compute_for_string (ChecksumType.MD5, normalized);
    }

    private string strip_invalid_entities (string original) {
        string p;

        p = original;

        try {
            foreach (var re in block_regexes) {
                p = re.replace_literal (p, -1, 0, "");
            }

            p = char_remove_regex.replace_literal (p, -1, 0, "");
            p = char_convert_regex.replace_literal (p, -1, 0, " ");
            p = space_compress_regex.replace_literal (p, -1, 0, " ");

            return p;
        } catch (RegexError error) {
            assert_not_reached ();
        }
    }
}
