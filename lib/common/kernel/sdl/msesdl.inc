{ derives the generic SDL define from the version define }
{$if (defined(usesdl2) and defined(usesdl3)) or
     (defined(usesdl2) and defined(usewayland)) or
     (defined(usesdl3) and defined(usewayland))}
{$error define only one of usesdl2, usesdl3, usewayland}
{$endif}
{$if defined(usesdl2) or defined(usesdl3) or defined(usewayland)}
{$define usesdl}
{$endif}