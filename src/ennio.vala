/* Copyright 2015 Michael Rutherford
*
* This file is part of Ennio Editor.
*
* Ennio Editor is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Ennio Editor is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Ennio Editor. If not, see http://www.gnu.org/licenses/.
*/

using Gtk;
namespace Ennio {
    class Ennio : Gtk.Window {
        public Ennio () {}
        public static string createfile (TextView tview, Label flabel, Window win) {
            string namef = "";
            var pick = new Gtk.FileChooserDialog("Create", 
                                        win,
                                        FileChooserAction.SAVE,
                                        "_Cancel",
                                        ResponseType.CANCEL,
                                        "_Create",                                           
                                        ResponseType.ACCEPT);
            if (pick.run () == ResponseType.ACCEPT) {
                namef = pick.get_filename ();
                flabel.set_label (namef);
                try {
                    tview.buffer.text = "";
                    var file = File.new_for_path (namef);
                    if (file.query_exists ()) {
                        file.delete ();
                    }
                    var file_stream = file.create (FileCreateFlags.REPLACE_DESTINATION);
                    var data_stream = new DataOutputStream (file_stream);
                    data_stream.put_string (tview.buffer.text);
                    pick.destroy ();
                } catch (Error e) {
                    stderr.printf ("Error %s\n", e.message);
                }
            }
            return namef; 
        }
        public static string savefile (string fname, TextView tview, Label flabel) {
            try {
                var file = File.new_for_path (fname);
                flabel.set_label (fname);
                if (file.query_exists ()) {
                    file.delete ();
                }
                var file_stream = file.create (FileCreateFlags.NONE);
                var data_stream = new DataOutputStream (file_stream);
                data_stream.put_string (tview.buffer.text);
            } catch (Error e) {
                stderr.printf ("Error %s\n", e.message);
            }
            return fname;
        }
        public static string openfile (string fname, TextView tview, 
                                            Label flabel, Window win) {
            string namef = fname;                
            var pick = new Gtk.FileChooserDialog("Open", 
                                        win,
                                        FileChooserAction.OPEN,
                                        "_Cancel",
                                        ResponseType.CANCEL,
                                        "_Open",                                           
                                        ResponseType.ACCEPT);
            pick.select_multiple = false;
            if (pick.run () == ResponseType.ACCEPT) {
                try {
                    string text;
                    FileUtils.get_contents (pick.get_filename (), out text);
                    tview.buffer.text = text;
                    namef = pick.get_filename ();
                    flabel.set_label (namef);
                } catch (Error e) {
                    stderr.printf ("Error: %s\n", e.message);
                }
                pick.destroy ();
            }
            return namef;
        }
        public static void aboutpage (Window win) {
            var dialog = new Gtk.AboutDialog ();
            dialog.set_destroy_with_parent (true);
            dialog.set_transient_for (win);
            dialog.set_modal (false);
            dialog.program_name = "Ennio Editor";
            dialog.comments = "A bare-bones GTK+ text editor written in Vala.";
            dialog.website = "michaelrutherford.github.io";
            dialog.version = "Version: 0.0";
            dialog.copyright = "Copyright © 2015 Michael Rutherford";
            dialog.license = "Ennio Editor is released under the GNU GPLv3 license.";
            dialog.wrap_license = true;
            dialog.present ();
            dialog.response.connect ((response_id) => {
                if (response_id == ResponseType.CANCEL) {
                    dialog.destroy ();
                } else if (response_id == ResponseType.DELETE_EVENT) {
                    dialog.destroy ();
                }           
            });
        }
        public static int main (string[] args) {
            Gtk.init (ref args);
            var editor = new Ennio ();
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
            var box2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 25);
            var newfile = new Button.with_label (" New ");
            var save = new Button.with_label ("Save ");
            var open = new Button.with_label ("Open ");
            var about = new Button.with_label ("About");
            var scrolled = new ScrolledWindow (null, null);
            var filelabel = new Gtk.Label ("Untitled");
            filelabel.set_line_wrap (true);
            var namefile = "";
            box2.pack_start (newfile, false, false, 0);
            box2.pack_start (save, false, false, 0);
            box2.pack_start (open, false, false, 0);
            box2.pack_start (about, false, false, 0);
            box.pack_start (filelabel, false, false, 0);
            box.pack_start (box2, false, false, 0);
            box.pack_start (scrolled, true, true, 0);
            box.hexpand = false;
            box.vexpand = false;
            var view = new Gtk.TextView ();
            view.set_wrap_mode (Gtk.WrapMode.NONE);
            view.set_indent (2);
            var filefont = new Pango.FontDescription ();
            filefont.set_family ("Monospace");
            filefont.set_size (9250);
            view.override_font (filefont);
            view.buffer.text = "";
            scrolled.add (view);
            editor.title = "Ennio Editor";
            editor.border_width = 10;
            editor.set_default_size (800, 700);
            editor.window_position = WindowPosition.CENTER;
            newfile.clicked.connect (() => {
                namefile = createfile (view, filelabel, editor);
            });
            save.clicked.connect (() => {
                namefile = savefile (namefile, view, filelabel);
            });
            open.clicked.connect (() => {
                namefile = openfile (namefile, view, filelabel, editor);
            });
            about.clicked.connect (() => {
                aboutpage (editor);
            });
            editor.add (box);
            editor.show_all ();
            editor.destroy.connect (Gtk.main_quit);
            Gtk.main ();
            return 0;
        }
    }
} 
