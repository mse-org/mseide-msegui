{ MSEgui Copyright (c) 2008 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}

function pro_listentoprocess(const aprochandle: prochandlety;
                             const adest: ievent; const adata: pointer): boolean;
             //false on error, limited to 63 items on windows
procedure pro_unlistentoprocess(const aprochandle: prochandlety;
                                     const adest: ievent);

