#!/bin/sh
#
# make_man_html.sh
# Use cat2html from Carl Lindberg's ManOpen to convert man page to HTML
#

/usr/bin/nroff -mandoc image2icns.1 | ./cat2html > image2icns.man.html
/usr/bin/nroff -mandoc icns2image.1 | ./cat2html > icns2image.man.html
/usr/bin/nroff -mandoc seticon.1 | ./cat2html > seticon.man.html
/usr/bin/nroff -mandoc geticon.1 | ./cat2html > geticon.man.html

