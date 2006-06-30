unit dllist;

interface

{$linklib pq}

{$i dllisttypes.inc}

function  DLNewList:PDllist;cdecl; external;
procedure DLFreeList(_para1:PDllist);cdecl; external;
function  DLNewElem(val : pointer) :PDlelem;cdecl;external;
procedure DLFreeElem(_para1:PDlelem);cdecl; external;
function  DLGetHead(_para1:PDllist):PDlelem;cdecl; external;
function  DLGetTail(_para1:PDllist):PDlelem;cdecl; external;
function  DLRemTail(l:PDllist):PDlelem;cdecl; external;
function  DLGetPred(_para1:PDlelem):PDlelem;cdecl; external;
function  DLGetSucc(_para1:PDlelem):PDlelem;cdecl; external;
procedure DLRemove(_para1:PDlelem);cdecl; external;
procedure DLAddHead(list:PDllist; node:PDlelem);cdecl; external;
procedure DLAddTail(list:PDllist; node:PDlelem);cdecl; external;
function  DLRemHead(list:PDllist):PDlelem;cdecl; external;

{ Macro translated }
Function  DLE_VAL(elem : PDlelem) : pointer;

implementation

// This function is also defined in DllistDyn!
Function DLE_VAL(elem : PDlelem) : pointer;
begin
  DLE_VAL:=elem^.dle_val
end;

end.
