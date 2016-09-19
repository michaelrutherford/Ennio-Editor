using Gtk;

namespace Ennio {
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
				show_about_dialog (
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

			SimpleAction dark = new SimpleAction.stateful ("dark", null, new Variant.boolean (false));
			dark.activate.connect(() => {
				Variant state = dark.get_state ();
				bool b = state.get_boolean ();
				dark.set_state (new Variant.boolean (!b));
				Gtk.Settings.get_default().set_property("gtk-application-prefer-dark-theme", !b);
			});
			this.add_action (dark);

			var menu = new GLib.Menu ();
			menu.append ("Dark", "app.dark");
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
			var doc = new Document(current_win.tabs);
            current_win.tabs.add_doc (doc);
		}
		public void savefile () {
			current_win.tabs.current.save();

		}
		public void openfile () {
            var pick = new FileChooserDialog("Open", 
                                                 current_win,
                                                 FileChooserAction.OPEN,
                                                 "_Cancel",
                                                 ResponseType.CANCEL,
                                                 "_Open",                                           
                                                 ResponseType.ACCEPT);
            pick.select_multiple = false;
            if (pick.run () == ResponseType.ACCEPT) {
				var doc = new Document.from_file(current_win.tabs, pick.get_file());
				current_win.tabs.add_doc (doc);
            }
            pick.destroy ();
		}
	}
}
