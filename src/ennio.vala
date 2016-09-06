/*
 * Copyright 2015-2016 Michael Rutherford
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *   
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

using Gtk;
namespace Ennio {
    public class Ennio : ApplicationWindow {
		private HeaderBar hbar = new HeaderBar();
		private Box hbarleft = new Box (Gtk.Orientation.HORIZONTAL, 0);
		private Box hbarright = new Box (Gtk.Orientation.HORIZONTAL, 0);
		public Ennio (Application app) {
			Object (application: app, title: "Unsaved");
			set_titlebar(hbar);
			icon_name = "text-editor";
			hbar.show_close_button = true;
			hbar.pack_start(hbarleft);
			hbar.pack_end(hbarright);
            var newfile = new Button.from_icon_name ("tab-new-symbolic", IconSize.BUTTON);
            var save = new Button.with_label ("Save ");
            var open = new Button.with_label ("Open ");
            var scrolled = new ScrolledWindow (null, null);
            var namefile = "";
            hbarleft.pack_start (open, false, false, 0);
            hbarleft.pack_start (newfile, false, false, 0);
            hbarleft.get_style_context().add_class ("linked");
            hbarright.pack_start (save, false, false, 0);
            this.add (scrolled);
            var view = new Gtk.TextView ();
            view.set_wrap_mode (Gtk.WrapMode.NONE);
            view.set_indent (2);
            var filefont = new Pango.FontDescription ();
            filefont.set_family ("Monospace");
            filefont.set_size (9250);
            view.override_font (filefont);
            view.buffer.text = "";
            scrolled.add (view);
            hbar.subtitle = "Ennio Editor";
            this.set_default_size (800, 700);
            this.window_position = WindowPosition.CENTER;
            newfile.clicked.connect (() => {
                namefile = createfile (view, this);
            });
            save.clicked.connect (() => {
                namefile = savefile (namefile, view);
            });
            open.clicked.connect (() => {
                namefile = openfile (namefile, view, this);
            });
		}
        public string createfile (TextView tview, Window win) {
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
                this.title = namef;
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
        public string savefile (string fname, TextView tview) {
            try {
                var file = File.new_for_path (fname);
                this.title = fname;
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
        public string openfile (string fname, TextView tview, Window win) {
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
                    this.title = namef;
                } catch (Error e) {
                    stderr.printf ("Error: %s\n", e.message);
                }
                pick.destroy ();
            }
            return namef;
        }
    }
    public class Application : Gtk.Application {
		public Application () {
			Object(application_id: "io.github.michaelrutherford.Ennio-Editor", flags: ApplicationFlags.FLAGS_NONE);
		}
		protected override void startup () {
			base.startup();
			SimpleAction about = new SimpleAction("about", null);
			about.activate.connect(() => {
				Gtk.show_about_dialog (
					active_window,
					"program_name", "Ennio Editor",
					"comments", "A bare-bones GTK+ text editor written in Vala.",
					"website", "michaelrutherford.github.io",
					"version", "Version: 0.0",
					"copyright", "Copyright © 2015-2016 Michael Rutherford \r\n Copyright © 2016 Zander Brown",
					"license", "Ennio Editor is released under the Apache v2.0 license.",
					"wrap_license", true,
					null
				);
			});
			this.add_action (about);
			
			SimpleAction quit = new SimpleAction("quit", null);
			quit.activate.connect(this.quit);
			this.add_action (quit);

			var menu = new GLib.Menu ();
			menu.append ("About", "app.about");
			menu.append ("Quit", "app.quit");
			app_menu = menu;
		}
		protected override void activate () {
            var editor = new Ennio (this);
            editor.show_all();
		}
	}
}

public static int main (string[] args) {
	Ennio.Application app = new Ennio.Application ();
	return app.run (args);
}
