/*
 * Copyright 2015-2016 Michael Rutherford
 * Copyright 2016 Zander
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
    public class Notebook : Gtk.Notebook {
		public Document current {
			get {
				return (Document) this.get_nth_page(
					this.get_current_page()
				);
			}
		}
		public Notebook () {
			scrollable = true;
			show_border = false;
		}
		public void add_doc(Document doc) {
			var label = new DocumentLabel("Untitled");
			label.close_clicked.connect(() => {
				var pagenum = this.page_num(doc);
				this.remove_page(pagenum);
				if (this.get_n_pages() <= 0) {
					add_doc(new Document(this));
				}
			});
            this.set_current_page(this.append_page (doc, doc.label));
            this.set_tab_reorderable(doc, true);
            doc.show_all();
		}
	}
    public class Document : ScrolledWindow {
		public SourceBuffer buffer = new SourceBuffer(null);
		public SourceView text;
		public string filepath;
		public DocumentLabel label;
		public SourceFile file;
		public Document (Notebook container, string path = "") {
			text = new SourceView.with_buffer(buffer);
            text.wrap_mode = WrapMode.NONE;
            text.indent = 2;
            text.monospace = true;
            text.buffer.text = "";
			text.auto_indent = true;
			text.indent_on_tab = true;
			text.show_line_numbers = true;
			text.highlight_current_line = true;
			text.smart_home_end = SourceSmartHomeEndType.BEFORE;
			text.auto_indent = true;
			text.show_right_margin = true;
			buffer.set_style_scheme(SourceStyleSchemeManager.get_default().get_scheme("cobalt"));
            add (text);
            filepath = path;
            label = new DocumentLabel("Untitled");
			label.close_clicked.connect(() => {
				var pagenum = container.page_num(this);
				container.remove_page(pagenum);
				if (container.get_n_pages() <= 0) {
					container.add_doc(new Document(container));
				}
			});
			buffer.changed.connect(() => {
				label.unsaved = true;
			});
		}
		public Document.from_file (Notebook container, File gfile) {
			this(container);
			var lm = new SourceLanguageManager();
			var language = lm.guess_language(gfile.get_path(), null);
			
			if (language != null) {
				buffer.language = language;
				buffer.highlight_syntax = true;
			} else {
				buffer.highlight_syntax = false;
			}

			label = new DocumentLabel.from_file(gfile);
			label.close_clicked.connect(() => {
				var pagenum = container.page_num(this);
				container.remove_page(pagenum);
				if (container.get_n_pages() <= 0) {
					container.add_doc(new Document(container));
				}
			});

			file = new SourceFile();
			file.location = gfile;
			var source_file_loader = new SourceFileLoader(buffer, file);
			label.unsaved = false;
			label.working = true;
			source_file_loader.load_async.begin (Priority.DEFAULT, null, () => {
				label.working = false;
				label.unsaved = false;
			});
		}
		public void save () {
			var source_file_saver = new SourceFileSaver(buffer, file);
			label.working = true;
			label.unsaved = false;
			buffer.set_modified(false);
			source_file_saver.save_async.begin (Priority.DEFAULT, null, () => {
				label.working = false;
			});
   		}
	}
	public class DocumentLabel : Box {
		public signal void close_clicked();
		private Spinner spinner = new Spinner();
		public string text {
			get { return label.label; }
			set { label.label = value; }
		}
		private bool _unsaved;
		public bool unsaved {
			get {
				return _unsaved;
			}
			set {
				_unsaved = value;
				label.attributes = new Pango.AttrList();
				if (value) {
					label.attributes.change(Pango.attr_style_new(Pango.Style.ITALIC));
				} else {
					label.attributes.change(Pango.attr_style_new(Pango.Style.NORMAL));
				}
			}
		}
		public bool working {
			get { return spinner.active; }
			set { spinner.active = value; }
		}
		private Label label;
		public DocumentLabel(string label_text) {
			orientation = Orientation.HORIZONTAL;
			spacing = 5;
				
			label = new Label(label_text);
			label.expand = true;
			label.margin_start = 45;
			
			pack_start(label, true, true, 0);
			
			var button = new Button();
			button.relief = ReliefStyle.NONE;
			button.focus_on_click = false;
			button.add(new Image.from_icon_name("window-close-symbolic", IconSize.MENU));
			button.clicked.connect(() => { close_clicked(); });
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
			}
			pack_end(button, false, false, 0);			   
			pack_end(spinner, false, false, 0);
			show_all();
		}
		public DocumentLabel.from_file (File file) {
			this(file.get_basename());
			tooltip_text = file.get_path();
		}
	}
}

public static int main (string[] args) {
	Ennio.Application app = new Ennio.Application ();
	return app.run (args);
}
