{
  Contains the types needed for dllist
}

{ Pointers to basic pascal types, inserted by h2pas conversion program.}
Type
  PCardinal = ^Cardinal;
  PReal     = ^Real;
  PDouble   = ^Double;

{ next element }
{ previous element }
{ value of the element }
{ what list this element is in }

type
   { Pointer types }
   PDllist= ^TDllist;
   PDlelem= ^TDlelem;

   TDlelem = record
        dle_next : PDlelem;
        dle_prev : PDlElem;
        dle_val : pointer;
        dle_list : PDllist;
     end;

   TDllist = record
        dll_head : PDlelem;
        dll_tail : PDlelem;
     end;

