using Gtk;

int main (string[] args) {
    Gst.init (ref args);
    Notify.init (Playmate.Application.APPNAME);

    var app = new Playmate.Application ();
    app.run (args);

    return 0;
}
