{ MSEgui Copyright (c) 1999-2010 by Martin Schreiber

    See the file COPYING.MSE, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
}
unit msegridsglob;
{$ifdef FPC}{$mode objfpc}{$h+}{$interfaces corba}{$endif}
interface

type
 cellpositionty = (cep_none,cep_nearest,cep_topleft,cep_top,cep_topright,
                   cep_bottomright,
                   cep_bottom,cep_bottomleft,cep_left,
                   cep_rowcentered,cep_rowcenteredif);

 celleventkindty = (cek_none,cek_enter,cek_exit,cek_select,
                    cek_focusedcellchanged,
                    cek_mousemove,cek_mousepark,cek_firstmousepark,
                    cek_buttonpress,cek_buttonrelease,
                    cek_mouseenter,cek_mouseleave,
                    cek_keydown,cek_keyup);

 focuscellactionty = (fca_none,fca_entergrid,fca_exitgrid,
                      fca_reverse,fca_focusin,fca_focusinforce,
                      fca_focusinshift,fca_focusinrepeater,fca_setfocusedcell,
                      fca_selectstart,fca_selectend);

 cellzonety = (cz_none,cz_default,cz_checkbox,cz_image,cz_caption);

implementation
end.
