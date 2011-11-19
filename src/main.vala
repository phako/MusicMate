using Gtk;

int main (string[] args) {
    Gst.init (ref args);

    var app = new Playmate.Application ();
    app.run (args);

    return 0;
}
