
         MSEide+MSEgui API Documentation
         ═══════════════════════════════

This directory contains a fpdoc project file [msegui-docs-project.xml]
for all of MSEgui. Currently their is very little actual documentation
content written, but hopefully this will change over time.

API documentation is a vital part of any framework's success. So we
welcome others to contribute to this effort so that MSEgui can finally
have some real API documentation. The idea is to keep adding little bits
at a time, and eventually it will become more and more useful to newcomers.

Saying than, the usage of fpdoc will generate skeleton [empty]
documentation entries, which in itself is still very useful to browse or
search.


Usage
─────
To generate new documentation, there are two requirements:

 1. You need the Free Pascal `fpdoc` tool available. It is easier if
    you add its location to your PATH environment variable, or create
    a symlink [Unix systems] to it in the `help/fpdoc/` directory.

 2. When building the documentation, fpdoc needs to be able to find the
    MSEgui source code.

    The standard directory hierarchy should already be as follows:

    <mseide+msegui>
      ├─ help/
      │  └─ fpdoc/
      └─ lib/

Then from within the `help/fpdoc/` directory you run the following
command:

  $> fpdoc --project=msegui-docs-project.xml

You can edit the msegui-docs-project.xml and switch it to HTML or CHM
output too. The INF output is by far the most efficient and fastest help
format though, and combined with Docview's features like searching, inline
annotations - very useful indeed.


Documenation Releases
─────────────────────
There are documentation releases which was create as samples and made
available on Github. These pre-built INF help files are downloadable from
the following URL, and viewable with the Docview Help Viewer.

   https://github.com/mse-org/mseide-msegui/releases/

To view INF help files, use fpGUI's Docview binaries downloadable from

   http://sourceforge.net/projects/fpgui/files/fpGUI/1.4/

See the screenshot in this directory of how the MSEgui API Documentation
looks in DocView.


                 ───────────[ end ]───────────
