# Ennio Editor
A minimalist GTK+ text editor written in Vala.

# TODO
* Improve error handling.
* Create 'Save As' Widget.
* Create 'Tools' Widget.
* Prevent 'About' Widget from opening more than once.
* Create a makefile.
* Create application icon.
* Create a desktop file.

# COMPILING
_Before running anything, ensure that gtk+-3.0, valac, and all of their dependencies are already installed._

In a terminal, navigate to the directory where Ennio.vala resides and run the following command:

> valac --pkg gtk+-3.0 Ennio.vala -o ennio

To run Ennio Editor after compilation, enter the following command into the terminal:

> ./ennio

# LINKS
* Apache: http://www.apache.org/licenses/LICENSE-2.0.html
* GTK+: http://www.gtk.org/
* Vala: https://wiki.gnome.org/Projects/Vala
