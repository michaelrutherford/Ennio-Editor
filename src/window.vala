using Gtk;

namespace Ennio {
    public class Window : ApplicationWindow {
		private HeaderBar hbar = new HeaderBar();
		private Box hbarleft = new Box (Orientation.HORIZONTAL, 0);
		private Box hbarright = new Box (Orientation.HORIZONTAL, 0);
		public Notebook tabs = new Notebook();
		private Button save = new Button.with_label ("Save");
		private Button open = new Button.with_label ("Open");
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

            save.action_name = "app.save";
            open.action_name = "app.open";
            
            hbarleft.pack_start (open, false, false, 0);
            hbarleft.pack_start (newfile, false, false, 0);
            hbarleft.get_style_context().add_class ("linked");
            hbarright.pack_start (save, false, false, 0);

			tabs.switch_page.connect((page) => {
				title = ((DocumentLabel) tabs.get_tab_label(page)).text;
			});
            
            this.add (tabs);
            this.set_default_size (800, 700);
            this.window_position = WindowPosition.CENTER;
		}
    }
}
