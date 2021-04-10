
         MSEgui+MSEide API Documentation
         ═══════════════════════════════

This directory contains a fpdoc project file [msegui-docs-project.xml]
for all of MSEgui. Currently their is very little actual documentation
content written, but hopefully this will change in the future.

API documentation is a vital part of any framework's success. So I
welcome others to contribute to this effort so that MSEgui can finally
have some real API documentation. The idea is to keep adding little bits
at a time (especially if Martin shares some knowledge via the mailing
list), and eventually it will become more and more useful to new comers.

Saying than, the usage of fpdoc will generate skeleton [empty]
documentation entries, which in itself is still very useful to browse or
search.


Usage
─────
To generate new documentation, there are two requirements:

 1. You need the Free Pascal fpdoc tool available.

 2. When building the documentation, fpdoc needs to be able to find the
    MSEgui source code.
     Windows:
        Copy the <msegui>/lib/ directory  into the
        <mseuniverse>/docs/msegui/ directory.

     Linux, FreeBSD:
        Simply create a symlink of your <msegui> directory pointing to
        <mseuniverse>/docs/msegui/

    You should end up with a directory hierarchy as follows:

    <mseuniverse>
      └─ docs/
         ├─ fpdoc/
         └─ msegui/
            └─ lib/

Then from within the docs/fpdoc/ directory you run the following
command:

  $> fpdoc --project=msegui-docs-project.xml

You can edit the msegui-docs-project.xml and switch it to HTML or CHM
output too. The INF output is by far the most efficient and fastest help
format though, and combined with Docview's features like searching, inline
annotations - very useful indeed.


Documenation Releases
─────────────────────
There are two documentation releases which was create as samples and made
available on Graeme's Github account (before all this got moved to
MSEUniverse). These pre-built INF help files are downloadable form the
following URL, and viewable with the DocView Help Viewer.

   https://github.com/graemeg/msegui/releases

To view INF help files, use fpGUI's DocView - binaries downloadable from

   http://sourceforge.net/projects/fpgui/files/fpGUI/1.4/

See the screenshot in this directory of how the MSEgui API Documentation
looks in DocView.


                 ───────────[ end ]───────────
