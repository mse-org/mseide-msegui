{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
type
 iprocmonitor = interface(inullinterface)
  procedure processdied(const aprochandle: prochandlety;
                 const aexecresult: integer; const adata: pointer);
 end;

function pro_listentoprocess(const aprochandle: prochandlety;
                             const adest: iprocmonitor; const adata: pointer): boolean;
             //false on error, limited to 63 items on windows
procedure pro_unlistentoprocess(const aprochandle: prochandlety;
                                     const adest: iprocmonitor);
procedure pro_killzombie(const aprochandle: prochandlety);

