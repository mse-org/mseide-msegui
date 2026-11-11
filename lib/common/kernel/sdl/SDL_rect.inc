{
  This file is part of:

    SDL3 for Pascal
    (https://github.com/PascalGameDevelopment/SDL3-for-Pascal)
    SPDX-License-Identifier: Zlib
}

{*
 * # CategoryRect
 *
 * Some helper functions for managing rectangles and 2D points, in both
 * integer and floating point versions.
  }

{*
 * The structure that defines a point (using integers).
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GetRectEnclosingPoints
 * \sa SDL_PointInRect
  }
type
  PPSDL_Point = ^PSDL_Point;
  PSDL_Point = ^TSDL_Point;
  TSDL_Point = record
    x: cint;
    y: cint;
  end;

{*
 * The structure that defines a point (using floating point values).
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_GetRectEnclosingPointsFloat
 * \sa SDL_PointInRectFloat
  }
  PPSDL_FPoint = ^PSDL_FPoint;
  PSDL_FPoint = ^TSDL_FPoint;
  TSDL_FPoint = record
    x: cfloat;
    y: cfloat;
  end;

{*
 * A rectangle, with the origin at the upper left (using integers).
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_RectEmpty
 * \sa SDL_RectsEqual
 * \sa SDL_HasRectIntersection
 * \sa SDL_GetRectIntersection
 * \sa SDL_GetRectAndLineIntersection
 * \sa SDL_GetRectUnion
 * \sa SDL_GetRectEnclosingPoints
  }
  PPSDL_Rect = ^PSDL_Rect;
  PSDL_Rect = ^TSDL_Rect;
  TSDL_Rect = record
    x: cint;
    y: cint;
    w: cint;
    h: cint;
  end;

{*
 * A rectangle stored using floating point values.
 *
 * The origin of the coordinate space is in the top-left, with increasing
 * values moving down and right. The properties `x` and `y` represent the
 * coordinates of the top-left corner of the rectangle.
 *
 * \since This struct is available since SDL 3.2.0.
 *
 * \sa SDL_RectEmptyFloat
 * \sa SDL_RectsEqualFloat
 * \sa SDL_RectsEqualEpsilon
 * \sa SDL_HasRectIntersectionFloat
 * \sa SDL_GetRectIntersectionFloat
 * \sa SDL_GetRectAndLineIntersectionFloat
 * \sa SDL_GetRectUnionFloat
 * \sa SDL_GetRectEnclosingPointsFloat
 * \sa SDL_PointInRectFloat
  }
  PPSDL_FRect = ^PSDL_FRect;
  PSDL_FRect = ^TSDL_FRect;
  TSDL_FRect = record
    x: cfloat;
    y: cfloat;
    w: cfloat;
    h: cfloat;
  end;

{*
 * Convert an SDL_Rect to SDL_FRect
 *
 * \param rect a pointer to an SDL_Rect.
 * \param frect a pointer filled in with the floating point representation of
 *              `rect`.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
procedure SDL_RectToFRect(const rect: PSDL_Rect; frect: PSDL_FRect); inline;

{*
 * Determine whether a point resides inside a rectangle.
 *
 * A point is considered part of a rectangle if both `p` and `r` are not nil,
 * and `p`'s x and y coordinates are >= to the rectangle's top left corner,
 * and < the rectangle's x+w and y+h. So a 1x1 rectangle considers point (0,0)
 * as "inside" and (0,1) as not.
 *
 * Note that this is a forced-inline function in a header, and not a public
 * API function available in the SDL library (which is to say, the code is
 * embedded in the calling program and the linker and dynamic loader will not
 * be able to find this function inside SDL itself).
 *
 * \param p the point to test.
 * \param r the rectangle to test.
 * \returns true if `p` is contained by `r`, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_PointInRect(const p: PSDL_Point; const r: PSDL_Rect): Boolean; inline;

{*
 * Determine whether a rectangle has no area.
 *
 * A rectangle is considered "empty" for this function if `r` is nil, or if
 * `r`'s width and/or height are <= 0.
 *
 * Note that this is a forced-inline function in a header, and not a public
 * API function available in the SDL library (which is to say, the code is
 * embedded in the calling program and the linker and dynamic loader will not
 * be able to find this function inside SDL itself).
 *
 * \param r the rectangle to test.
 * \returns true if the rectangle is "empty", false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_RectEmpty(const r: PSDL_Rect): Boolean; inline;

{*
 * Determine whether two rectangles are equal.
 *
 * Rectangles are considered equal if both are not nil and each of their x,
 * y, width and height match.
 *
 * Note that this is a forced-inline function in a header, and not a public
 * API function available in the SDL library (which is to say, the code is
 * embedded in the calling program and the linker and dynamic loader will not
 * be able to find this function inside SDL itself).
 *
 * \param a the first rectangle to test.
 * \param b the second rectangle to test.
 * \returns true if the rectangles are equal, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
 function SDL_RectsEqual(const a: PSDL_Rect; const b: PSDL_Rect): Boolean; inline;

{*
 * Determine whether two rectangles intersect.
 *
 * If either pointer is nil the function will return false.
 *
 * \param A an SDL_Rect structure representing the first rectangle.
 * \param B an SDL_Rect structure representing the second rectangle.
 * \returns true if there is an intersection, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRectIntersection
  }
function SDL_HasRectIntersection(A: PSDL_Rect; B: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasRectIntersection' {$ENDIF} {$ENDIF};

{*
 * Calculate the intersection of two rectangles.
 *
 * If `result` is nil then this function will return false.
 *
 * \param A an SDL_Rect structure representing the first rectangle.
 * \param B an SDL_Rect structure representing the second rectangle.
 * \param result an SDL_Rect structure filled in with the intersection of
 *               rectangles `A` and `B`.
 * \returns true if there is an intersection, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HasRectIntersection
  }
function SDL_GetRectIntersection(A: PSDL_Rect; B: PSDL_Rect; result: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRectIntersection' {$ENDIF} {$ENDIF};

{*
 * Calculate the union of two rectangles.
 *
 * \param A an SDL_Rect structure representing the first rectangle.
 * \param B an SDL_Rect structure representing the second rectangle.
 * \param result an SDL_Rect structure filled in with the union of rectangles
 *               `A` and `B`.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRectUnion(A: PSDL_Rect; B: PSDL_Rect; result: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRectUnion' {$ENDIF} {$ENDIF};

{*
 * Calculate a minimal rectangle enclosing a set of points.
 *
 * If `clip` is not nil then only points inside of the clipping rectangle are
 * considered.
 *
 * \param points an array of SDL_Point structures representing points to be
 *               enclosed.
 * \param count the number of structures in the `points` array.
 * \param clip an SDL_Rect used for clipping or nil to enclose all points.
 * \param result an SDL_Rect structure filled in with the minimal enclosing
 *               rectangle.
 * \returns true if any points were enclosed or false if all the points were
 *          outside of the clipping rectangle.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRectEnclosingPoints(points: PSDL_Point; count: cint; clip: PSDL_Rect; result: PSDL_Rect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRectEnclosingPoints' {$ENDIF} {$ENDIF};

{*
 * Calculate the intersection of a rectangle and line segment.
 *
 * This function is used to clip a line segment to a rectangle. A line segment
 * contained entirely within the rectangle or that does not intersect will
 * remain unchanged. A line segment that crosses the rectangle at either or
 * both ends will be clipped to the boundary of the rectangle and the new
 * coordinates saved in `X1`, `Y1`, `X2`, and/or `Y2` as necessary.
 *
 * \param rect an SDL_Rect structure representing the rectangle to intersect.
 * \param X1 a pointer to the starting X-coordinate of the line.
 * \param Y1 a pointer to the starting Y-coordinate of the line.
 * \param X2 a pointer to the ending X-coordinate of the line.
 * \param Y2 a pointer to the ending Y-coordinate of the line.
 * \returns true if there is an intersection, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRectAndLineIntersection(rect: PSDL_Rect; X1: pcint; Y1: pcint; X2: pcint; Y2: pcint): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRectAndLineIntersection' {$ENDIF} {$ENDIF};

{ SDL_FRect versions...  }

{*
 * Determine whether a point resides inside a floating point rectangle.
 *
 * A point is considered part of a rectangle if both `p` and `r` are not nil,
 * and `p`'s x and y coordinates are >= to the rectangle's top left corner,
 * and <= the rectangle's x+w and y+h. So a 1x1 rectangle considers point
 * (0,0) and (0,1) as "inside" and (0,2) as not.
 *
 * Note that this is a forced-inline function in a header, and not a public
 * API function available in the SDL library (which is to say, the code is
 * embedded in the calling program and the linker and dynamic loader will not
 * be able to find this function inside SDL itself).
 *
 * \param p the point to test.
 * \param r the rectangle to test.
 * \returns true if `p` is contained by `r`, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_PointInRectFloat(const p: PSDL_FPoint; const r: PSDL_FRect): Boolean; inline;

{*
 * Determine whether a floating point rectangle takes no space.
 *
 * A rectangle is considered "empty" for this function if `r` is nil, or if
 * `r`'s width and/or height are < 0.0f.
 *
 * Note that this is a forced-inline function in a header, and not a public
 * API function available in the SDL library (which is to say, the code is
 * embedded in the calling program and the linker and dynamic loader will not
 * be able to find this function inside SDL itself).
 *
 * \param r the rectangle to test.
 * \returns true if the rectangle is "empty", false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_RectEmptyFloat(const r: PSDL_FRect): Boolean; inline;

{*
 * Determine whether two floating point rectangles are equal, within some
 * given epsilon.
 *
 * Rectangles are considered equal if both are not nil and each of their x,
 * y, width and height are within `epsilon` of each other. If you don't know
 * what value to use for `epsilon`, you should call the SDL_RectsEqualFloat
 * function instead.
 *
 * Note that this is a forced-inline function in a header, and not a public
 * API function available in the SDL library (which is to say, the code is
 * embedded in the calling program and the linker and dynamic loader will not
 * be able to find this function inside SDL itself).
 *
 * \param a the first rectangle to test.
 * \param b the second rectangle to test.
 * \param epsilon the epsilon value for comparison.
 * \returns true if the rectangles are equal, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RectsEqualFloat
  }
function SDL_RectsEqualEpsilon(const a: PSDL_Frect; const b: PSDL_FRect; epsilon: cfloat): Boolean; inline;

{*
 * Determine whether two floating point rectangles are equal, within a default
 * epsilon.
 *
 * Rectangles are considered equal if both are not nil and each of their x,
 * y, width and height are within SDL_FLT_EPSILON of each other. This is often
 * a reasonable way to compare two floating point rectangles and deal with the
 * slight precision variations in floating point calculations that tend to pop
 * up.
 *
 * Note that this is a forced-inline function in a header, and not a public
 * API function available in the SDL library (which is to say, the code is
 * embedded in the calling program and the linker and dynamic loader will not
 * be able to find this function inside SDL itself).
 *
 * \param a the first rectangle to test.
 * \param b the second rectangle to test.
 * \returns true if the rectangles are equal, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_RectsEqualEpsilon
  }
function SDL_RectsEqualFloat(const a: PSDL_FRect; b: PSDL_FRect): Boolean; inline;

{*
 * Determine whether two rectangles intersect with float precision.
 *
 * If either pointer is nil the function will return false.
 *
 * \param A an SDL_FRect structure representing the first rectangle.
 * \param B an SDL_FRect structure representing the second rectangle.
 * \returns true if there is an intersection, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_GetRectIntersection
  }
function SDL_HasRectIntersectionFloat(A: PSDL_FRect; B: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_HasRectIntersectionFloat' {$ENDIF} {$ENDIF};

{*
 * Calculate the intersection of two rectangles with float precision.
 *
 * If `result` is nil then this function will return false.
 *
 * \param A an SDL_FRect structure representing the first rectangle.
 * \param B an SDL_FRect structure representing the second rectangle.
 * \param result an SDL_FRect structure filled in with the intersection of
 *               rectangles `A` and `B`.
 * \returns true if there is an intersection, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
 *
 * \sa SDL_HasRectIntersectionFloat
  }
function SDL_GetRectIntersectionFloat(A: PSDL_FRect; B: PSDL_FRect; result: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRectIntersectionFloat' {$ENDIF} {$ENDIF};

{*
 * Calculate the union of two rectangles with float precision.
 *
 * \param A an SDL_FRect structure representing the first rectangle.
 * \param B an SDL_FRect structure representing the second rectangle.
 * \param result an SDL_FRect structure filled in with the union of rectangles
 *               `A` and `B`.
 * \returns true on success or false on failure; call SDL_GetError() for more
 *          information.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRectUnionFloat(A: PSDL_FRect; B: PSDL_FRect; result: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRectUnionFloat' {$ENDIF} {$ENDIF};

{*
 * Calculate a minimal rectangle enclosing a set of points with float
 * precision.
 *
 * If `clip` is not nil then only points inside of the clipping rectangle are
 * considered.
 *
 * \param points an array of SDL_FPoint structures representing points to be
 *               enclosed.
 * \param count the number of structures in the `points` array.
 * \param clip an SDL_FRect used for clipping or nil to enclose all points.
 * \param result an SDL_FRect structure filled in with the minimal enclosing
 *               rectangle.
 * \returns true if any points were enclosed or false if all the points were
 *          outside of the clipping rectangle.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRectEnclosingPointsFloat(points: PSDL_FPoint; count: cint; clip: PSDL_FRect; result: PSDL_FRect): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRectEnclosingPointsFloat' {$ENDIF} {$ENDIF};

{*
 * Calculate the intersection of a rectangle and line segment with float
 * precision.
 *
 * This function is used to clip a line segment to a rectangle. A line segment
 * contained entirely within the rectangle or that does not intersect will
 * remain unchanged. A line segment that crosses the rectangle at either or
 * both ends will be clipped to the boundary of the rectangle and the new
 * coordinates saved in `X1`, `Y1`, `X2`, and/or `Y2` as necessary.
 *
 * \param rect an SDL_FRect structure representing the rectangle to intersect.
 * \param X1 a pointer to the starting X-coordinate of the line.
 * \param Y1 a pointer to the starting Y-coordinate of the line.
 * \param X2 a pointer to the ending X-coordinate of the line.
 * \param Y2 a pointer to the ending Y-coordinate of the line.
 * \returns true if there is an intersection, false otherwise.
 *
 * \threadsafety It is safe to call this function from any thread.
 *
 * \since This function is available since SDL 3.2.0.
  }
function SDL_GetRectAndLineIntersectionFloat(rect: PSDL_FRect; X1: pcfloat; Y1: pcfloat; X2: pcfloat; Y2: pcfloat): Boolean; cdecl;
  external SDL_LibName {$IFDEF DELPHI} {$IFDEF MACOS} name '_SDL_GetRectAndLineIntersectionFloat' {$ENDIF} {$ENDIF};


