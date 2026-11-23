{ MSEgui gui interface, selected at compile time:
    -dusehybrid    X11 and Wayland, chosen at run time (mseguiintfhybrid.inc)
    -dusewayland   pure Wayland (mseguiintfwl.inc)
    no define      X11 (mseguiintfx11.inc) }
unit mseguiintf;
{$ifdef usehybrid}
 {$include mseguiintfhybrid.inc}
{$else}
 {$ifdef usewayland}
  {$include mseguiintfwl.inc}
 {$else}
  {$include mseguiintfx11.inc}
 {$endif}
{$endif}