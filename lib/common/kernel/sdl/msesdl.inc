{ derives the generic SDL define from the version define }
{$if defined(usesdl2) and defined(usesdl3)}
 {$error define only one of usesdl2 or usesdl3}
{$endif}
{$if defined(usesdl2) or defined(usesdl3)}
 {$define usesdl}
{$endif}
