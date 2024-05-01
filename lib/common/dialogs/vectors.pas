UNIT vectors;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

INTERFACE

USES
  SysUtils, Classes, MClasses, msegraphutils;

OPERATOR  +  (P1, P2: PointTy): PointTy;
OPERATOR  -  (P1, P2: PointTy): PointTy;
OPERATOR  =  (P1, P2: PointTy): boolean;
OPERATOR <>  (P1, P2: PointTy): boolean;
OPERATOR  *  (P1, P2: PointTy): integer;             // scalar product
OPERATOR  *  (scale: integer; P: PointTy): PointTy;  // scaling
OPERATOR  *  (P: PointTy; scale: integer): PointTy;  // scaling
OPERATOR DIV (P: PointTy; scale: integer): PointTy;
OPERATOR :=  (CONST inArray: ARRAY OF integer) P: PointTy;


IMPLEMENTATION

// Arithhmetic operator overloading for Points should really exist:
OPERATOR + (P1, P2: PointTy): PointTy;
 BEGIN
   Result.x:= P1.x+ P2.x;
   Result.y:= P1.y+ P2.y;
 END;

OPERATOR - (P1, P2: PointTy): PointTy;
 BEGIN
   Result.x:= P1.x- P2.x;
   Result.y:= P1.y- P2.y;
 END;

OPERATOR = (P1, P2: PointTy): boolean;
 BEGIN
   Result:= (P1.x = P2.x) AND (P1.y = P2.y);
 END;

OPERATOR <> (P1, P2: PointTy): boolean;
 BEGIN
   Result:= (P1.x <> P2.x) OR (P1.y <> P2.y);
 END;

OPERATOR * (P1, P2: PointTy): integer;
 BEGIN
   Result:= (P1.x* P2.x)+ (P1.y* P2.y);
 END;

OPERATOR * (scale: integer; P: PointTy): PointTy;
 BEGIN
   Result.x:= P.x* scale; Result.y:= P.y* scale;
 END;

OPERATOR DIV (P: PointTy; scale: integer): PointTy;
 BEGIN
   Result.x:= P.x DIV scale; Result.y:= P.y DIV scale;
 END;

OPERATOR * (P: PointTy; scale: integer): PointTy;
 BEGIN
   Result.x:= P.x* scale; Result.y:= P.y* scale;
 END;

OPERATOR := (CONST inArray: ARRAY OF integer) P: PointTy;
 BEGIN
   P.x:= inArray [0];
   P.y:= inArray [1];
 END;

END.
