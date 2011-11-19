using Gtk;

int main (string[] args) {
    Gst.init (ref args);

    var app = new PlaymateApplication ();
    app.run (args);

    return 0;
}
