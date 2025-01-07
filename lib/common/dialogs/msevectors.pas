UNIT msevectors;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}

INTERFACE
{ 2-dimensional vector operations

  Provides:
  1: Operators
  - Addition and Subtraction of "PointTy" vectors
  - Scaiing - multiplication with an integer scalar
  - Scalar product yielding length rounded to integer
  - Comparison for equal and not-equal
  - Composition of a vector from an ARRAY OF integer
  2: Functions
  - Length of vector, yielding "real" type value
  - Angle between 2 vectors, yielding "real" type value (radians)
}
USES
{$ifdef pointty}
  SysUtils, Math, msegraphutils;
{$else}
  SysUtils, Math;

TYPE
  PointTy = RECORD
              x, y: integer;
            END;
{$endif}

OPERATOR  +  (P1, P2: PointTy): PointTy; INLINE;
OPERATOR  -  (P1, P2: PointTy): PointTy; INLINE;
OPERATOR  =  (P1, P2: PointTy): boolean; INLINE;
OPERATOR <>  (P1, P2: PointTy): boolean; INLINE;
OPERATOR  *  (P1, P2: PointTy): integer; INLINE;             // scalar product
OPERATOR  *  (scale: integer; P: PointTy): PointTy; INLINE;  // scaling
OPERATOR  *  (P: PointTy; scale: integer): PointTy; INLINE; OVERLOAD;
OPERATOR DIV (P: PointTy; scale: integer): PointTy; INLINE;
OPERATOR :=  (CONST inArray: ARRAY OF integer) P: PointTy; INLINE;

FUNCTION length (P: PointTy): real;INLINE;
FUNCTION angle (P1, P2: PointTy): real;


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


FUNCTION length (P: PointTy): real;
 BEGIN
   length:= sqrt (P* P);
 END;

FUNCTION angle (P1, P2: PointTy): real;
 BEGIN
   Result:= arccos ((P1* P2)/(length (P1)* length (P2)));
 END;

END.
