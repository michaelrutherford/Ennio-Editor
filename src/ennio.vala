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
    public class Window : ApplicationWindow {
		private HeaderBar hbar = new HeaderBar();
		private Box hbarleft = new Box (Gtk.Orientation.HORIZONTAL, 0);
		private Box hbarright = new Box (Gtk.Orientation.HORIZONTAL, 0);
		public Notebook tabs = new Notebook();
		public Window (Application app) {
			Object (application: app);
			set_titlebar(hbar);
			icon_name = "accessories-text-editor";
            hbar.subtitle = "Ennio Editor";
            hbar.title = "Unsaved";
			hbar.show_close_button = true;
			hbar.pack_start(hbarleft);
			hbar.pack_end(hbarright);
            var newfile = new Button.from_icon_name ("tab-new-symbolic", IconSize.BUTTON);
            newfile.action_name = "app.new";

            var save = new Button.with_label ("Save");
            save.action_name = "app.save";

            var open = new Button.with_label ("Open");
            open.action_name = "app.open";
            
            hbarleft.pack_start (open, false, false, 0);
            hbarleft.pack_start (newfile, false, false, 0);
            hbarleft.get_style_context().add_class ("linked");
            hbarright.pack_start (save, false, false, 0);

			tabs.scrollable = true;

            this.add (tabs);
            this.set_default_size (800, 700);
            this.window_position = WindowPosition.CENTER;
		}
        public string createfile (TextView tview) {
            string namef = "";
            var pick = new Gtk.FileChooserDialog("Create", 
                                                 this,
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
                } catch (Error e) {
                    stderr.printf ("Error %s\n", e.message);
                }
            }
            pick.destroy ();
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
    }
    public class Document : ScrolledWindow {
		public TextView text = new TextView();
		public Document () {
            text.wrap_mode = WrapMode.NONE;
            text.indent = 2;
            text.monospace = true;
            text.buffer.text = "";
            add (text);
		}
	}
	public class TabLabel : Box {
		public signal void close_clicked();
		private Spinner spinner = new Spinner();
		public string text {
			get { return label.label; }
			set { label.label = value; }
		}
		private Label label;
		public TabLabel(string label_text) {
			orientation = Gtk.Orientation.HORIZONTAL;
			spacing = 5;

			pack_start(spinner, false, false, 0);
	
			label = new Label(label_text);
			pack_start(label, true, true, 0);
		   
			var button = new Button();
			button.relief = ReliefStyle.NONE;
			button.focus_on_click = false;
			button.add(new Image.from_icon_name("window-close-symbolic", IconSize.MENU));
			button.clicked.connect(button_clicked);
			try {
				var data =  ".button {\n" +
						"-GtkButton-default-border : 0px;\n" +
						"-GtkButton-default-outside-border : 0px;\n" +
						"-GtkButton-inner-border: 0px;\n" +
						"-GtkWidget-focus-line-width : 0px;\n" +
						"-GtkWidget-focus-padding : 0px;\n" +
						"padding: 0px;\n" +
						"}";
				var provider = new CssProvider();
				provider.load_from_data(data);
				button.get_style_context().add_provider(provider, 600);
			} catch (Error e) {
			} finally {
				pack_start(button, false, false, 0);			   
				show_all();
				spinner.visible = false;
			}
		}
		public void button_clicked() {
			close_clicked();
		}
		public void start_working() {
			spinner.start();
			spinner.visible = true;
		}
		public void stop_working() {
			spinner.stop();
			spinner.visible = false;
		}
	}
    public class Application : Gtk.Application {
		public Window current_win {
			get { return (Window) active_window; }
		}
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

			SimpleAction newtab = new SimpleAction("new", null);
			newtab.activate.connect(this.newtab);
			this.add_action (newtab);

			SimpleAction openact = new SimpleAction("open", null);
			openact.activate.connect(openfile);
			this.add_action (openact);

			SimpleAction saveact = new SimpleAction("save", null);
			saveact.activate.connect(savefile);
			this.add_action (saveact);

			var menu = new GLib.Menu ();
			menu.append ("About", "app.about");
			menu.append ("Quit", "app.quit");
			app_menu = menu;
		}
		protected override void activate () {
            var editor = new Window (this);
            editor.show_all();
            newtab();
		}
		public void newtab () {
			var doc = new Document();
            var label = new TabLabel("Untitled");
            current_win.tabs.append_page (doc, label);
            doc.show_all();
		}
		public void savefile () {
		}
		public void openfile () {
            var pick = new Gtk.FileChooserDialog("Open", 
                                                 current_win,
                                                 FileChooserAction.OPEN,
                                                 "_Cancel",
                                                 ResponseType.CANCEL,
                                                 "_Open",                                           
                                                 ResponseType.ACCEPT);
            pick.select_multiple = false;
            if (pick.run () == ResponseType.ACCEPT) {
                try {
					newtab();
					((TabLabel) current_win.tabs.get_tab_label(
						current_win.tabs.get_nth_page(current_win.tabs.get_current_page())
					)).text = pick.get_filename ();
                    string text;
                    FileUtils.get_contents (pick.get_filename (), out text);
					((Document) current_win.tabs.get_nth_page(
						current_win.tabs.get_current_page()
					)).text.buffer.text = text;
                } catch (Error e) {
                    stderr.printf ("Error: %s\n", e.message);
                }
            }
            pick.destroy ();
		}
	}
}

public static int main (string[] args) {
	Ennio.Application app = new Ennio.Application ();
	return app.run (args);
}
