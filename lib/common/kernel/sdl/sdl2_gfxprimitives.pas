(* 

SDL2_gfxPrimitives.c: graphics primitives for SDL2 renderers

Copyright (C) 2012  Andreas Schiffler

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source
distribution.

Andreas Schiffler -- aschiffler at ferzkopp dot net

Converted to FreePascal by : Sri Wahono

*)

unit sdl2_gfxprimitives;
{$ifdef FPC}{$mode objfpc}{$h+}{$endif}
interface
uses
 msetypes,msesystypes,mseguiglob,ctypes,msekeyboard,msesysutils,msegraphutils,
 sdl4msegui,math;

(* ---- Structures *)

(*!
brief The structure passed to the internal Bresenham iterator.
*)
type
	SDL2_gfxBresenhamIterator = record 
		x, y: integer;
		dx, dy, s1, s2, swapdir, error: Integer;
		count: cardinal;
	end;
	PSDL2_gfxBresenhamIterator = ^SDL2_gfxBresenhamIterator;

(*!
brief The structure passed to the internal Murphy iterator.
*)
type
	SDL2_gfxMurphyIterator = record 
		renderer: SDL_Renderer;
		u, v: Integer;		(* delta x , delta y *)
		ku, kt, kv, kd: Integer;	(* loop constants *)
		oct2: Integer;
		quad4: Integer;
		last1x, last1y, last2x, last2y, first1x, first1y, first2x, first2y, tempx, tempy: integer;
	end;
	PSDL2_gfxMurphyIterator = ^SDL2_gfxMurphyIterator;

	(* Pixel *)

	function pixelColor(renderer: SDL_Renderer; x: integer; y: integer; color: cardinal): Integer;

	function pixelRGBA(renderer: SDL_Renderer; x: integer; y: integer; 
    	r: byte; g: byte; b: byte; a: byte): Integer;

	(* Horizontal line *)

	function hlineColor(renderer: SDL_Renderer; x1: integer; x2: integer; y: integer; color: cardinal): Integer;
	function hlineRGBA(renderer: SDL_Renderer; x1: integer; x2: integer; 
     	y: integer; r: byte; g: byte; b: byte; a: byte): Integer;

	(* Vertical line *)

	function vlineColor(renderer: SDL_Renderer; x: integer; y1: integer; y2: integer; color: cardinal): Integer;
	function vlineRGBA(renderer: SDL_Renderer; x: integer; y1: integer; y2: integer; 
    	r: byte; g: byte; b: byte; a: byte): Integer;

	(* Rectangle *)

	function rectangleColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	color: cardinal): Integer;
	
	function rectangleRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Rounded-Corner Rectangle *)

	function roundedRectangleColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	rad: integer; 
	color: cardinal): Integer;
	
	function roundedRectangleRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Filled rectangle (Box) *)

	function boxColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	color: cardinal): Integer;
	
	function boxRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Rounded-Corner Filled rectangle (Box) *)

	function roundedBoxColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	rad: integer; 
	color: cardinal): Integer;
	
	function roundedBoxRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Line *)

	function lineColor(renderer: SDL_Renderer; x1: integer; y1: integer; 
    	x2: integer; y2: integer; color: cardinal): Integer;
	function lineRGBA(renderer: SDL_Renderer; x1: integer; y1: integer; 
    	x2: integer; y2: integer; r: byte; g: byte; b: byte; a: byte): Integer;

	(* AA Line *)

	function aalineColor(var renderer: SDL_Renderer; x1: integer; y1: integer; x2: integer; 
    	y2: integer; color: cardinal): Integer;
	function aalineRGBA(var renderer: SDL_Renderer; x1: integer; y1: integer; 
    	x2: integer; y2: integer; r: byte; g: byte; b: byte; a: byte): Integer;

	(* Thick Line *)
	function thickLineColor(var renderer: SDL_Renderer; x1: integer; 
    	y1: integer; x2: integer; y2: integer; width: byte; color: cardinal): Integer;
	function thickLineRGBA(var renderer: SDL_Renderer; x1: integer; y1: integer; 
    	x2: integer; y2: integer; width: byte; r: byte; g: byte; b: byte; a: byte): Integer;

	(* Circle *)

	function circleColor(renderer: SDL_Renderer; x: integer; y: integer; rad: integer; color: cardinal): Integer;
	function circleRGBA(renderer: SDL_Renderer; x: integer; y: integer; 
		rad: integer; r: byte; g: byte; b: byte; a: byte): Integer;

	(* Arc *)

	function arcColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	color: cardinal): Integer;
	function arcRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* AA Circle *)

	function aacircleColor(renderer: SDL_Renderer; x: integer; y: integer; rad: integer; color: cardinal): Integer;
	function aacircleRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Filled Circle *)

	function filledCircleColor(renderer: SDL_Renderer; x: integer; y: integer; rad: integer; color: cardinal): Integer;
	function filledCircleRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Ellipse *)

	function ellipseColor(renderer: SDL_Renderer; x: integer; y: integer; 
		rx: integer; ry: integer; color: cardinal): Integer;

	function ellipseRGBA(renderer: SDL_Renderer; x: integer; y: integer; 
		rx: integer; ry: integer; r: byte; g: byte; b: byte; a: byte): Integer;

	(* AA Ellipse *)

	function aaellipseColor(renderer: SDL_Renderer; x: integer; y: integer; 
		rx: integer; ry: integer; color: cardinal): Integer;

	function aaellipseRGBA(renderer: SDL_Renderer; x: integer; y: integer; 
		rx: integer; ry: integer; r: byte; g: byte; b: byte; a: byte): Integer;

	(* Filled Ellipse *)

	function filledEllipseColor(renderer: SDL_Renderer; x: integer; y: integer; 
		rx: integer; ry: integer; color: cardinal): Integer;

	function filledEllipseRGBA(renderer: SDL_Renderer; x: integer; y: integer; 
		rx: integer; ry: integer; r: byte; g: byte; b: byte; a: byte): Integer;

	(* Pie *)

	function pieColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	color: cardinal): Integer;
	function pieRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Filled Pie *)

	function filledPieColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	color: cardinal): Integer;
	function filledPieRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Trigon *)

	function trigonColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	color: cardinal): Integer;
	
	function trigonRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* AA-Trigon *)

	function aatrigonColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	color: cardinal): Integer;
	function aatrigonRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Filled Trigon *)

	function filledTrigonColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	color: cardinal): Integer;
	function filledTrigonRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Polygon *)

	function polygonColor(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	color: cardinal): Integer;
	
	function polygonRGBA(
	renderer: SDL_Renderer; 
	var vx: pinteger; 
	var vy: pinteger; 
	n: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* AA-Polygon *)

	function aapolygonColor(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	color: cardinal): Integer;
	
	function aapolygonRGBA(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Filled Polygon *)

	function filledPolygonColor(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	color: cardinal): Integer;
	
	function filledPolygonRGBA(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

	(* Textured Polygon *)

	function texturedPolygon(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	texture: PSDL_Surface; 
	texture_dx: Integer; 
	texture_dy: Integer): Integer;

	(* Bezier *)

	function bezierColor(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	s: Integer; 
	color: cardinal): Integer;
	
	function bezierRGBA(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	s: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;

(*!
brief Global vertex cArray to use if optional parameters are not given in filledPolygonMT calls.

Note: Used for non-multithreaded (default) operation of filledPolygonMT.
*)
var
 gfxPrimitivesPolyIntsGlobal : pinteger;

(*!
brief Flag indicating if global vertex cArray was already allocated.

Note: Used for non-multithreaded (default) operation of filledPolygonMT.
*)
 gfxPrimitivesPolyAllocatedGlobal : integer;

implementation



(* ---- Pixel *)

(*!
brief Draw pixel  in currently set color.

param renderer The renderer to draw on.
param x X (horizontal) coordinate of the pixel.
param y Y (vertical) coordinate of the pixel.

returns Returns 0 on success, -1 on failure.
*)
function pixel(renderer: SDL_Renderer; x: integer; y: integer): Integer;
begin 
	result:= SDL_RenderDrawPoint(renderer, x, y);
end;

(*!
brief Draw pixel with blending enabled if a<255.

param renderer The renderer to draw on.
param x X (horizontal) coordinate of the pixel.
param y Y (vertical) coordinate of the pixel.
param color The color value of the pixel to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function pixelColor(renderer: SDL_Renderer; x: integer; y: integer; color: cardinal): Integer;
var
 c: pbyte;
begin 
	c := @color; 
	result:= pixelRGBA(renderer, x, y, c[0], c[1], c[2], c[3]);
end;

(*!
brief Draw pixel with blending enabled if a<255.

param renderer The renderer to draw on.
param x X (horizontal) coordinate of the pixel.
param y Y (vertical) coordinate of the pixel.
param r The red color value of the pixel to draw. 
param g The green color value of the pixel to draw.
param b The blue color value of the pixel to draw.
param a The alpha value of the pixel to draw.

returns Returns 0 on success, -1 on failure.
*)
function pixelRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	result := 0;
	if (a = 255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result:= result or SDL_RenderDrawPoint(renderer, x, y);
 end;

(*!
brief Draw pixel with blending enabled and using alpha weight on color.

param renderer The renderer to draw on.
param x The horizontal coordinate of the pixel.
param y The vertical position of the pixel.
param r The red color value of the pixel to draw. 
param g The green color value of the pixel to draw.
param b The blue color value of the pixel to draw.
param a The alpha value of the pixel to draw.
param weight The weight multiplied into the alpha value of the pixel.

returns Returns 0 on success, -1 on failure.
*)
function pixelRGBAWeight(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte; 
	weight: cardinal): Integer;
var
	ax: cardinal;
begin 
	(*
	* Modify Alpha by weight 
	*)
	ax := a;
	ax := ((ax * weight) shr 8);
	if (ax > 255) then  begin 
		a := 255;
	end else begin 
		a := byte(ax and $000000ff);
	 end;

	result:= pixelRGBA(renderer, x, y, r, g, b, a);
 end;

(* ---- Hline *)

(*!
brief Draw horizontal line in currently set color

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. left) of the line.
param x2 X coordinate of the second point (i.e. right) of the line.
param y Y coordinate of the points of the line.

returns Returns 0 on success, -1 on failure.
*)
function hline(renderer: SDL_Renderer; x1: integer; x2: integer; y: integer): Integer;
begin 
	result:= SDL_RenderDrawLine(renderer, x1, y, x2, y);;
 end;


(*!
brief Draw horizontal line with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. left) of the line.
param x2 X coordinate of the second point (i.e. right) of the line.
param y Y coordinate of the points of the line.
param color The color value of the line to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function hlineColor(renderer: SDL_Renderer; x1: integer; x2: integer; y: integer; color: cardinal): Integer;
var
 c: pbyte;
begin 
	c := @color; 
	result:= hlineRGBA(renderer, x1, x2, y, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw horizontal line with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. left) of the line.
param x2 X coordinate of the second point (i.e. right) of the line.
param y Y coordinate of the points of the line.
param r The red value of the line to draw. 
param g The green value of the line to draw. 
param b The blue value of the line to draw. 
param a The alpha value of the line to draw. 

returns Returns 0 on success, -1 on failure.
*)
function hlineRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	x2: integer; 
	y: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	result := 0;
	if (a = 255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result:= result or SDL_RenderDrawLine(renderer, x1, y, x2, y);
 end;

(* ---- Vline *)

(*!
brief Draw vertical line with blending.

param renderer The renderer to draw on.
param x X coordinate of the points of the line.
param y1 Y coordinate of the first point (i.e. top) of the line.
param y2 Y coordinate of the second point (i.e. bottom) of the line.
param color The color value of the line to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function vlineColor(renderer: SDL_Renderer; x: integer; y1: integer; y2: integer; color: cardinal): Integer;
var
 c: pbyte;
begin 
	c := @color; 
	result:= vlineRGBA(renderer, x, y1, y2, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw vertical line with blending.

param renderer The renderer to draw on.
param x X coordinate of the points of the line.
param y1 Y coordinate of the first point (i.e. top) of the line.
param y2 Y coordinate of the second point (i.e. bottom) of the line.
param r The red value of the line to draw. 
param g The green value of the line to draw. 
param b The blue value of the line to draw. 
param a The alpha value of the line to draw. 

returns Returns 0 on success, -1 on failure.
*)
function vlineRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y1: integer; 
	y2: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	result := 0;
	if (a = 255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);
	result:= result or SDL_RenderDrawLine(renderer, x, y1, x, y2);
 end;

(* ---- Rectangle *)

(*!
brief Draw rectangle with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. top right) of the rectangle.
param y1 Y coordinate of the first point (i.e. top right) of the rectangle.
param x2 X coordinate of the second point (i.e. bottom left) of the rectangle.
param y2 Y coordinate of the second point (i.e. bottom left) of the rectangle.
param color The color value of the rectangle to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function rectangleColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	color: cardinal): Integer;
var
 c: pbyte;
begin 
	c := @color; 
	result:= rectangleRGBA(renderer, x1, y1, x2, y2, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw rectangle with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. top right) of the rectangle.
param y1 Y coordinate of the first point (i.e. top right) of the rectangle.
param x2 X coordinate of the second point (i.e. bottom left) of the rectangle.
param y2 Y coordinate of the second point (i.e. bottom left) of the rectangle.
param r The red value of the rectangle to draw. 
param g The green value of the rectangle to draw. 
param b The blue value of the rectangle to draw. 
param a The alpha value of the rectangle to draw. 

returns Returns 0 on success, -1 on failure.
*)
function rectangleRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	tmp: integer;
	rect: SDL_Rect;
begin 

	(*
	* Test for special cases of straight lines or single point 
	*)
	if (x1 = x2) then  begin 
		if (y1 = y2) then  begin 
			result:= (pixelRGBA(renderer, x1, y1, r, g, b, a));
		 end else begin 
			result:= (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		 end;
	 end else begin 
		if (y1 = y2) then  begin 
			result:= (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		 end;
	 end;

	(*
	* Swap x1, x2 if required 
	*)
	if (x1 > x2) then  begin 
		tmp := x1;
		x1 := x2;
		x2 := tmp;
	 end;

	(*
	* Swap y1, y2 if required 
	*)
	if (y1 > y2) then  begin 
		tmp := y1;
		y1 := y2;
		y2 := tmp;
	 end;

	(* 
	* Create destination rect
	*)	
	rect.x := x1;
	rect.y := y1;
	rect.w := x2 - x1;
	rect.h := y2 - y1;
	
	(*
	* Draw
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);	
	result:= result or SDL_RenderDrawRect(renderer,  @rect);
 end;

(* ---- Rounded Rectangle *)

(*!
brief Draw rounded-corner rectangle with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. top right) of the rectangle.
param y1 Y coordinate of the first point (i.e. top right) of the rectangle.
param x2 X coordinate of the second point (i.e. bottom left) of the rectangle.
param y2 Y coordinate of the second point (i.e. bottom left) of the rectangle.
param rad The radius of the corner arc.
param color The color value of the rectangle to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function roundedRectangleColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	rad: integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c := @color; 
	result:= roundedRectangleRGBA(renderer, x1, y1, x2, y2, rad, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw rounded-corner rectangle with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. top right) of the rectangle.
param y1 Y coordinate of the first point (i.e. top right) of the rectangle.
param x2 X coordinate of the second point (i.e. bottom left) of the rectangle.
param y2 Y coordinate of the second point (i.e. bottom left) of the rectangle.
param rad The radius of the corner arc.
param r The red value of the rectangle to draw. 
param g The green value of the rectangle to draw. 
param b The blue value of the rectangle to draw. 
param a The alpha value of the rectangle to draw. 

returns Returns 0 on success, -1 on failure.
*)
function roundedRectangleRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	tmp, w, h, xx1, xx2, yy1, yy2: integer;
begin 
	result := 0;
	
	(*
	* Check renderer
	*)
	if (renderer = 0) then 
	begin 
		result:= -1;
	 end;

	(*
	* Check radius vor valid range
	*)
	if (rad < 0) then  begin 
		result:= -1;
	 end;

	(*
	* Special  - no rounding
	*)
	if (rad = 0) then  begin 
		result:= rectangleRGBA(renderer, x1, y1, x2, y2, r, g, b, a);
	 end;

	(*
	* Test for special cases of straight lines or single point 
	*)
	if (x1 = x2) then  begin 
		if (y1 = y2) then  begin 
			result:= (pixelRGBA(renderer, x1, y1, r, g, b, a));
		 end else begin 
			result:= (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		 end;
	 end else begin 
		if (y1 = y2) then  begin 
			result:= (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		 end;
	 end;

	(*
	* Swap x1, x2 if required 
	*)
	if (x1 > x2) then  begin 
		tmp := x1;
		x1 := x2;
		x2 := tmp;
	 end;

	(*
	* Swap y1, y2 if required 
	*)
	if (y1 > y2) then  begin 
		tmp := y1;
		y1 := y2;
		y2 := tmp;
	 end;

	(*
	* Calculate width and height 
	*)
	w := x2 - x1;
	h := y2 - y1;

	(*
	* Maybe adjust radius
	*)
	if ((rad * 2) > w) then   
	begin 
		rad := round(w / 2);
	 end;
	if ((rad * 2) > h) then 
	begin 
		rad := round(h / 2);
	 end;

	(*
	* Draw corners
	*)
	xx1 := x1 + rad;
	xx2 := x2 - rad;
	yy1 := y1 + rad;
	yy2 := y2 - rad;
	result:= result or arcRGBA(renderer, xx1, yy1, rad, 180, 270, r, g, b, a);
	result:= result or arcRGBA(renderer, xx2, yy1, rad, 270, 360, r, g, b, a);
	result:= result or arcRGBA(renderer, xx1, yy2, rad,  90, 180, r, g, b, a);
	result:= result or arcRGBA(renderer, xx2, yy2, rad,   0,  90, r, g, b, a);

	(*
	* Draw lines
	*)
	if (xx1 <= xx2) then  begin 
		result:= result or hlineRGBA(renderer, xx1, xx2, y1, r, g, b, a);
		result:= result or hlineRGBA(renderer, xx1, xx2, y2, r, g, b, a);
	 end;
	if (yy1 <= yy2) then  begin 
		result:= result or vlineRGBA(renderer, x1, yy1, yy2, r, g, b, a);
		result:= result or vlineRGBA(renderer, x2, yy1, yy2, r, g, b, a);
	 end;

	result:= result;
 end;

(* ---- Rounded Box *)

(*!
brief Draw rounded-corner box (filled rectangle) with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. top right) of the box.
param y1 Y coordinate of the first point (i.e. top right) of the box.
param x2 X coordinate of the second point (i.e. bottom left) of the box.
param y2 Y coordinate of the second point (i.e. bottom left) of the box.
param rad The radius of the corner arcs of the box.
param color The color value of the box to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function roundedBoxColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	rad: integer; 
	color: cardinal): Integer;
var
 c: pbyte;
begin 
	c:= @color;
	result:= roundedBoxRGBA(renderer, x1, y1, x2, y2, rad, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw rounded-corner box (filled rectangle) with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. top right) of the box.
param y1 Y coordinate of the first point (i.e. top right) of the box.
param x2 X coordinate of the second point (i.e. bottom left) of the box.
param y2 Y coordinate of the second point (i.e. bottom left) of the box.
param rad The radius of the corner arcs of the box.
param r The red value of the box to draw. 
param g The green value of the box to draw. 
param b The blue value of the box to draw. 
param a The alpha value of the box to draw. 

returns Returns 0 on success, -1 on failure.
*)
function roundedBoxRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	w, h, tmp, xx1, xx2, yy1, yy2: integer;

begin 
	result := 0;

	(* 
	* Check destination renderer 
	*)
	if (renderer = 0) then 
	begin 
		result:= -1;
	 end;

	(*
	* Check radius vor valid range
	*)
	if (rad < 0) then  begin 
		result:= -1;
	 end;

	(*
	* Special  - no rounding
	*)
	if (rad = 0) then  begin 
		result:= rectangleRGBA(renderer, x1, y1, x2, y2, r, g, b, a);
	 end;

	(*
	* Test for special cases of straight lines or single point 
	*)
	if (x1 = x2) then  begin 
		if (y1 = y2) then  begin 
			result:= (pixelRGBA(renderer, x1, y1, r, g, b, a));
		 end else begin 
			result:= (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		 end;
	 end else begin 
		if (y1 = y2) then  begin 
			result:= (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		 end;
	 end;

	(*
	* Swap x1, x2 if required 
	*)
	if (x1 > x2) then  begin 
		tmp := x1;
		x1 := x2;
		x2 := tmp;
	 end;

	(*
	* Swap y1, y2 if required 
	*)
	if (y1 > y2) then  begin 
		tmp := y1;
		y1 := y2;
		y2 := tmp;
	 end;

	(*
	* Calculate width and height 
	*)
	w := x2 - x1;
	h := y2 - y1;

	(*
	* Maybe adjust radius
	*)
	if ((rad * 2) > w) then   
	begin 
		rad := round(w / 2);
	 end;
	if ((rad * 2) > h) then 
	begin 
		rad := round(h / 2);
	 end;

	(*
	* Draw corners
	*)
	xx1 := x1 + rad;
	xx2 := x2 - rad;
	yy1 := y1 + rad;
	yy2 := y2 - rad;
	result:= result or filledPieRGBA(renderer, xx1, yy1, rad, 180, 270, r, g, b, a);
	result:= result or filledPieRGBA(renderer, xx2, yy1, rad, 270, 360, r, g, b, a);
	result:= result or filledPieRGBA(renderer, xx1, yy2, rad,  90, 180, r, g, b, a);
	result:= result or filledPieRGBA(renderer, xx2, yy2, rad,   0,  90, r, g, b, a);

	(*
	* Draw body
	*)
	xx1:= xx1 + 2;
	xx2:= xx2 - 2;
	yy1:= yy1 + 2;
	yy2:= yy2 - 2;
	if (xx1 <= xx2) then  begin 
		result:= result or boxRGBA(renderer, xx1, y1, xx2, y2, r, g, b, a);
	 end;
	if (yy1 <= yy2) then  begin 
		result:= result or boxRGBA(renderer, x1, yy1, xx1-1, yy2, r, g, b, a);
		result:= result or boxRGBA(renderer, xx2+1, yy1, x2, yy2, r, g, b, a);
	 end;

	result:= result;
 end;

(* ---- Box *)

(*!
brief Draw box (filled rectangle) with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. top right) of the box.
param y1 Y coordinate of the first point (i.e. top right) of the box.
param x2 X coordinate of the second point (i.e. bottom left) of the box.
param y2 Y coordinate of the second point (i.e. bottom left) of the box.
param color The color value of the box to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function boxColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= boxRGBA(renderer, x1, y1, x2, y2, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw box (filled rectangle) with blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. top right) of the box.
param y1 Y coordinate of the first point (i.e. top right) of the box.
param x2 X coordinate of the second point (i.e. bottom left) of the box.
param y2 Y coordinate of the second point (i.e. bottom left) of the box.
param r The red value of the box to draw. 
param g The green value of the box to draw. 
param b The blue value of the box to draw. 
param a The alpha value of the box to draw.

returns Returns 0 on success, -1 on failure.
*)
function boxRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	tmp: integer;
	rect: SDL_Rect;
begin 

	(*
	* Test for special cases of straight lines or single point 
	*)
	if (x1 = x2) then  begin 
		if (y1 = y2) then  begin 
			result:= (pixelRGBA(renderer, x1, y1, r, g, b, a));
		 end else begin 
			result:= (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		 end;
	 end else begin 
		if (y1 = y2) then  begin 
			result:= (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		 end;
	 end;

	(*
	* Swap x1, x2 if required 
	*)
	if (x1 > x2) then  begin 
		tmp := x1;
		x1 := x2;
		x2 := tmp;
	 end;

	(*
	* Swap y1, y2 if required 
	*)
	if (y1 > y2) then  begin 
		tmp := y1;
		y1 := y2;
		y2 := tmp;
	 end;

	(* 
	* Create destination rect
	*)	
	rect.x := x1;
	rect.y := y1;
	rect.w := x2 - x1;
	rect.h := y2 - y1;
	
	(*
	* Draw
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);	
	result:= result or SDL_RenderFillRect(renderer,  @rect);
	
 end;

(* ----- Line *)

(*!
brief Draw line with alpha blending using the currently set color.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the line.
param y1 Y coordinate of the first point of the line.
param x2 X coordinate of the second point of the line.
param y2 Y coordinate of the second point of the line.

returns Returns 0 on success, -1 on failure.
*)
function line(renderer: SDL_Renderer; x1: integer; y1: integer; x2: integer; y2: integer): Integer;
begin 
	(*
	* Draw
	*)
	result:= SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
 end;

(*!
brief Draw line with alpha blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the line.
param y1 Y coordinate of the first point of the line.
param x2 X coordinate of the second point of the line.
param y2 Y coordinate of the seond point of the line.
param color The color value of the line to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function lineColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	color: cardinal): Integer;
var
 c: pbyte;
begin 
	c:= @color;
	result:= lineRGBA(renderer, x1, y1, x2, y2, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw line with alpha blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the line.
param y1 Y coordinate of the first point of the line.
param x2 X coordinate of the second point of the line.
param y2 Y coordinate of the second point of the line.
param r The red value of the line to draw. 
param g The green value of the line to draw. 
param b The blue value of the line to draw. 
param a The alpha value of the line to draw.

returns Returns 0 on success, -1 on failure.
*)
function lineRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	(*
	* Draw
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);	
	result:= result or SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
	
 end;

(* ---- AA Line *)

const AAlevels =  256;
const AAbits =  8;

(*!
brief Internal cFunction to draw anti-aliased line with alpha blending and endpoint control.

This implementation of the Wu antialiasing code is based on Mike Abrash's
DDJ article which was reprinted as Chapter 42 of his Graphics Programming
Black Book, but has been optimized to work with SDL and utilizes 32-bit
fixed-point arithmetic by A. Schiffler. The endpoint control allows the
supression to draw the last pixel useful for rendering continous aa-lines
with alpha<255.

param dst The surface to draw on.
param x1 X coordinate of the first point of the aa-line.
param y1 Y coordinate of the first point of the aa-line.
param x2 X coordinate of the second point of the aa-line.
param y2 Y coordinate of the second point of the aa-line.
param r The red value of the aa-line to draw. 
param g The green value of the aa-line to draw. 
param b The blue value of the aa-line to draw. 
param a The alpha value of the aa-line to draw.
param draw_endpoint Flag indicating if the endpoint should be drawn; draw if non-zero.

returns Returns 0 on success, -1 on failure.
*)
function _aalineRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte; 
	draw_endpoint: boolean): Integer;
var
	xx0, yy0, xx1, yy1: integer;
	intshift, erracc, erradj: cardinal;
	erracctmp, wgt, wgtcompmask: cardinal;
	dx, dy, tmp, xdir, y0p1, x0pxdir: Integer;
begin 

	(*
	* Keep on working with 32bit numbers 
	*)
	xx0 := x1;
	yy0 := y1;
	xx1 := x2;
	yy1 := y2;

	(*
	* Reorder points if required 
	*)
	if (yy0 > yy1) then  begin 
		tmp := yy0;
		yy0 := yy1;
		yy1 := tmp;
		tmp := xx0;
		xx0 := xx1;
		xx1 := tmp;
	 end;

	(*
	* Calculate distance 
	*)
	dx := xx1 - xx0;
	dy := yy1 - yy0;

	(*
	* Check for special cases 
	*)
	if (dx = 0) then  begin 
		(*
		* Vertical line 
		*)
		if (draw_endpoint) then 
		begin 
			result:= (vlineRGBA(renderer, x1, y1, y2, r, g, b, a));
		 end else begin 
			if (dy>0) then  begin 
				result:= (vlineRGBA(renderer, x1, yy0, yy0+dy, r, g, b, a));
			 end else begin 
				result:= (pixelRGBA(renderer, x1, y1, r, g, b, a));
			 end;
		 end;
	 end else if (dy = 0) then  begin 
		(*
		* Horizontal line 
		*)
		if (draw_endpoint) then 
		begin 
			result:= (hlineRGBA(renderer, x1, x2, y1, r, g, b, a));
		 end else begin 
			if (dx>0) then  begin 
				result:= (hlineRGBA(renderer, xx0, xx0+dx, y1, r, g, b, a));
			 end else begin 
				result:= (pixelRGBA(renderer, x1, y1, r, g, b, a));
			 end;
		 end;
	 end else if ((dx = dy) and (draw_endpoint)) then  begin 
		(*
		* Diagonal line (with endpoint)
		*)
		result:= (lineRGBA(renderer, x1, y1, x2, y2,  r, g, b, a));
	 end;

	(*
	* Adjust for negative dx and set xdir 
	*)
	if (dx >= 0) then  begin 
		xdir := 1;
	 end else begin 
		xdir := -1;
		dx := (-dx);
	 end;

	(*
	* Line is not horizontal, vertical or diagonal (with endpoint)
	*)
	result := 0;

	(*
	* Zero accumulator 
	*)
	erracc := 0;

	(*
* {$ of bits by which to shift erracc to get intensity level}
	*)
	intshift := 32 - AAbits;

	(*
	* Mask used to flip all bits in an intensity weighting 
	*)
	wgtcompmask := AAlevels - 1;

	(*
	* Draw the initial pixel in the foreground color 
	*)
	result:= result or pixelRGBA(renderer, x1, y1, r, g, b, a);

	(*
	* x-major or y-major? 
	*)
	if (dy > dx) then  begin 

		(*
		* y-major.  Calculate 16-bit fixed point fractional part of a pixel that
		* X advances every time Y advances 1 pixel, truncating the result so that
		* we won't overrun the endpoint along the X axis 
		*)
		(*
		* Not-so-portable version: erradj := ((Uint64)dx shl 32) / (Uint64)dy; 
		*)
		erradj := round((dx shl 16) / dy) shl 16;

		(*
		* draw all pixels other than the first and last 
		*)
		x0pxdir := xx0 + xdir;
		dy:= dy -2;
		while dy>0 do begin 
			erracctmp := erracc;
			erracc:= erracc + erradj;
			if (erracc <= erracctmp) then  begin 
				(*
				* rollover in error accumulator, x coord advances 
				*)
				xx0 := x0pxdir;
				x0pxdir:= x0pxdir + xdir;
			 end;
			yy0:= yy0 + 1;		(* y-major so always advance Y *)

			(*
			* the AAbits most significant bits of erracc give us the intensity
			* weighting for this pixel, and the complement of the weighting for
			* the paired pixel. 
			*)
			wgt := (erracc shr intshift) and 255;
			result:= result or pixelRGBAWeight (renderer, xx0, yy0, r, g, b, a, 255 - wgt);
			result:= result or pixelRGBAWeight (renderer, x0pxdir, yy0, r, g, b, a, wgt);
			dy:= dy -2;
		end;

	 end else begin 

		(*
		* x-major line.  Calculate 16-bit fixed-point fractional part of a pixel
		* that Y advances each time X advances 1 pixel, truncating the result so
		* that we won't overrun the endpoint along the X axis. 
		*)
		(*
		* Not-so-portable version: erradj := ((Uint64)dy shl 32) / (Uint64)dx; 
		*)
		erradj := round((dy shl 16) / dx) shl 16;

		(*
		* draw all pixels other than the first and last 
		*)
		y0p1 := yy0 + 1;
		dx:= dx -2;
		while dx>0 do begin 

			erracctmp := erracc;
			erracc:= erracc + erradj;
			if (erracc <= erracctmp) then  begin 
				(*
				* Accumulator turned over, advance y 
				*)
				yy0 := y0p1;
				y0p1:= y0p1 + 1;
			 end;
			xx0:= xx0 + xdir;	(* x-major so always advance X *)
			(*
			* the AAbits most significant bits of erracc give us the intensity
			* weighting for this pixel, and the complement of the weighting for
			* the paired pixel. 
			*)
			wgt := (erracc shr intshift) and 255;
			result:= result or pixelRGBAWeight (renderer, xx0, yy0, r, g, b, a, 255 - wgt);
			result:= result or pixelRGBAWeight (renderer, xx0, y0p1, r, g, b, a, wgt);
			dx:= dx -2;
		end;
	 end;

	(*
	* Do we have to draw the endpoint 
	*)
	if (draw_endpoint) then  begin 
		(*
		* Draw final pixel, always exactly intersected by the line and doesn't
		* need to be weighted. 
		*)
		result:= result or pixelRGBA (renderer, x2, y2, r, g, b, a);
	 end;

	result:= (result);
 end;

(*!
brief Draw anti-aliased line with alpha blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the aa-line.
param y1 Y coordinate of the first point of the aa-line.
param x2 X coordinate of the second point of the aa-line.
param y2 Y coordinate of the second point of the aa-line.
param color The color value of the aa-line to draw ($RRGGBBAA).

returns Returns 0 on success, -1 on failure.
*)
function aalineColor(
	var renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= _aalineRGBA(renderer, x1, y1, x2, y2, c[0], c[1], c[2], c[3], true);
 end;

(*!
brief Draw anti-aliased line with alpha blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the aa-line.
param y1 Y coordinate of the first point of the aa-line.
param x2 X coordinate of the second point of the aa-line.
param y2 Y coordinate of the second point of the aa-line.
param r The red value of the aa-line to draw. 
param g The green value of the aa-line to draw. 
param b The blue value of the aa-line to draw. 
param a The alpha value of the aa-line to draw.

returns Returns 0 on success, -1 on failure.
*)
function aalineRGBA(
	var renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	result:= _aalineRGBA(renderer, x1, y1, x2, y2, r, g, b, a, true);
 end;

(* ----- Circle *)

(*!
brief Draw circle with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the circle.
param y Y coordinate of the center of the circle.
param rad Radius in pixels of the circle.
param color The color value of the circle to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function circleColor(renderer: SDL_Renderer; x: integer; y: integer; rad: integer; color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= ellipseRGBA(renderer, x, y, rad, rad, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw circle with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the circle.
param y Y coordinate of the center of the circle.
param rad Radius in pixels of the circle.
param r The red value of the circle to draw. 
param g The green value of the circle to draw. 
param b The blue value of the circle to draw. 
param a The alpha value of the circle to draw.

returns Returns 0 on success, -1 on failure.
*)
function circleRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	result:= ellipseRGBA(renderer, x, y, rad, rad, r, g, b, a);
 end;

(* ----- Arc *)

(*!
brief Arc with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the arc.
param y Y coordinate of the center of the arc.
param rad Radius in pixels of the arc.
param start Starting radius in degrees of the arc. 0 degrees is down, increasing counterclockwise.
param end Ending radius in degrees of the arc. 0 degrees is down, increasing counterclockwise.
param color The color value of the arc to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function arcColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= arcRGBA(renderer, x, y, rad, astart, aend, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Arc with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the arc.
param y Y coordinate of the center of the arc.
param rad Radius in pixels of the arc.
param start Starting radius in degrees of the arc. 0 degrees is down, increasing counterclockwise.
param end Ending radius in degrees of the arc. 0 degrees is down, increasing counterclockwise.
param r The red value of the arc to draw. 
param g The green value of the arc to draw. 
param b The blue value of the arc to draw. 
param a The alpha value of the arc to draw.

returns Returns 0 on success, -1 on failure.
*)
function arcRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	cx, cy, df, d_e, d_se, xpcx, xmcx, xpcy, xmcy,
	ypcy, ymcy, ypcx, ymcx: integer;
	drawoct: byte;
	startoct, endoct, oct, stopval_start, stopval_end : integer;
	dstart, dend, temp : Double;

begin 
	cx := 0;
	cy := rad;
	df := 1 - rad;
	d_e := 3;
	d_se := -2 * rad + 5;
	stopval_start := 0;
	stopval_end := 0;
	temp := 0;

	(*
	* Sanity check radius 
	*)
	if (rad < 0) then  begin 
		result:= (-1);
	 end;

	(*
	* Special  for rad=0 - draw a point 
	*)
	if (rad = 0) then  begin 
		result:= (pixelRGBA(renderer, x, y, r, g, b, a));
	 end;

	// Octant labelling
	//      
	//  \ 5 | 6 /
	//   \  |  /
	//  4 \ | / 7
	//     \|/
	//------+------ +x
	//     /|\
	//  3 / | \ 0
	//   /  |  \
	//  / 2 | 1 \
	//      +y

	// Initially reset bitmask to 0x00000000
	// the set whether or not to keep drawing a given octant.
	// For example: 0x00111100 means we're drawing in octants 2-5
	drawoct := 0; 

	(*
	* Fixup angles
	*)
	astart:= astart mod 360;
	aend:= aend mod 360;
	// 0 <= start & end < 360; note that sometimes start > end - if so, arc goes back through 0.
	while (astart < 0) do begin
	 astart:= astart + 360;
	end;
	while (aend < 0) do begin
	 aend:= aend + 360;
	end;
	astart:= astart mod 360;
	aend:= aend mod 360;

	// now, we find which octants we're drawing in.
	startoct := round(astart / 45);
	endoct := round(aend / 45);
	oct := startoct - 1; // we increment as first step in loop

	// stopval_start, stopval_end; 
	// what values of cx to stop at.
	repeat 
		oct := (oct + 1) mod 8;

		if (oct = startoct) then  begin 
			// need to compute stopval_start for this octant.  Look at picture above if this is unclear
			dstart := astart;
			case (oct)  of 
			 3: begin
  				temp := sin(dstart * pi / 180);
  				break;
				end;
			 6: begin
				temp := cos(dstart * pi / 180);
				break;
				end;
			 5: begin
				temp := -cos(dstart * pi / 180);
				break;
				end;
			 7: begin
				temp := -sin(dstart * pi / 180);
				break;
				end;
			 end;
			temp:= temp * rad;
			stopval_start := round(temp); // always round down.

			// This isn't arbitrary, but requires graph paper to explain well.
			// The basic idea is that we're always changing drawoct after we draw, so we
			// stop immediately after we render the last sensible pixel at x = ((int)temp).

			// and whether to draw in this octant initially
			if (oct mod 2)>0 then 
			 drawoct:= drawoct or (1 shl oct) // this is basically like saying drawoct[oct] = true, if drawoct were a bool array
			else
			 drawoct:= drawoct and 255 - (1 shl oct); // this is basically like saying drawoct[oct] = false
		 end;
		if (oct = endoct) then  begin 
			// need to compute stopval_end for this octant
			dend := aend;
			case (oct) of
			 3: begin
				temp := sin(dend * pi / 180);
				break;
				end;
			 6: begin
				temp := cos(dend * pi / 180);
				break;
				end;
			 5: begin
				temp := -cos(dend * pi / 180);
				break;
				end;
			 7: begin
				temp := -sin(dend * pi / 180);
				break;
				end;
			 end;
			temp:= temp * rad;
			stopval_end := round(temp);

			// and whether to draw in this octant initially
			if (startoct = endoct) then 	begin 
				// note:      we start drawing, stop, then start again in this case
				// otherwise: we only draw in this octant, so initialize it to false, it will get set back to true
				if (astart > aend) then  begin 
					// unfortunately, if we're in the same octant and need to draw over the whole circle, 
					// we need to set the rest to true, because the while loop will end at the bottom.
					drawoct := 255;
				 end else begin 
					drawoct:= drawoct and 255 - (1 shl oct);
				 end;
			 end; 
			if (oct mod 2)>0 then
			 drawoct:= drawoct and 255 - (1 shl oct)
			else
			 drawoct:= drawoct or (1 shl oct);
		 end else if (oct <> startoct) then  begin  // already verified that it's != endoct
			drawoct:= drawoct or (1 shl oct); // draw this entire segment
		 end;
	 until (oct <> endoct);

	// so now we have what octants to draw and when to draw them. all that's left is the actual raster code.

	(*
	* Set color 
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);

	(*
	* Draw arc 
	*)
	repeat 
		ypcy := y + cy;
		ymcy := y - cy;
		if (cx > 0) then  begin 
			xpcx := x + cx;
			xmcx := x - cx;

			// always check if we're drawing a certain octant before adding a pixel to that octant.
			if (drawoct and 4)>0  then result:= result or pixel(renderer, xmcx, ypcy);
			if (drawoct and 2)>0 then result:= result or pixel(renderer, xpcx, ypcy);
			if (drawoct and 32)>0 then result:= result or pixel(renderer, xmcx, ymcy);
			if (drawoct and 64)>0 then result:= result or pixel(renderer, xpcx, ymcy);
		 end else begin 
			if (drawoct and 96)>0 then result:= result or pixel(renderer, x, ymcy);
			if (drawoct and 6)>0 then  result:= result or pixel(renderer, x, ypcy);
		 end;

		xpcy := x + cy;
		xmcy := x - cy;
		if (cx > 0) and (cx <> cy) then  begin 
			ypcx := y + cx;
			ymcx := y - cx;
			if (drawoct and 8)>0 then result:= result or pixel(renderer, xmcy, ypcx);
			if (drawoct and 1)>0 then result:= result or pixel(renderer, xpcy, ypcx);
			if (drawoct and 16)>0 then result:= result or pixel(renderer, xmcy, ymcx);
			if (drawoct and 128)>0 then result:= result or pixel(renderer, xpcy, ymcx);
		 end else if (cx = 0) then  begin 
			if (drawoct and 24)>0 then result:= result or pixel(renderer, xmcy, y);
			if (drawoct and 129)>0 then result:= result or pixel(renderer, xpcy, y);
		 end;

		(*
		* Update whether we're drawing an octant
		*)
		if (stopval_start = cx) then  begin 
			// works like an on-off switch.  
			// This is just in case start & end are in the same octant.
			if (drawoct and (1 shl startoct))>0 then 
			 drawoct:= drawoct and 255 - (1 shl startoct)
			else
			 drawoct:= drawoct or (1 shl startoct);
		 end;
		if (stopval_end = cx) then  begin 
			if (drawoct and (1 shl endoct))>0 then 
			 drawoct:= drawoct and 255 - (1 shl endoct)
			else
			 drawoct:= drawoct or (1 shl endoct);
		 end;

		(*
		* Update pixels
		*)
		if (df < 0) then  begin 
			df:= df + d_e;
			d_e:= d_e + 2;
			d_se:= d_se + 2;
		 end else begin 
			df:= df + d_se;
			d_e:= d_e + 2;
			d_se:= d_se + 4;
			cy:= cy - 1;
		 end;
		cx:= cx + 1;
	 until (cx <= cy);
 end;

(* ----- AA Circle *)

(*!
brief Draw anti-aliased circle with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the aa-circle.
param y Y coordinate of the center of the aa-circle.
param rad Radius in pixels of the aa-circle.
param color The color value of the aa-circle to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function aacircleColor(renderer: SDL_Renderer; x: integer; y: integer; rad: integer; color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= aaellipseRGBA(renderer, x, y, rad, rad, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw anti-aliased circle with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the aa-circle.
param y Y coordinate of the center of the aa-circle.
param rad Radius in pixels of the aa-circle.
param r The red value of the aa-circle to draw. 
param g The green value of the aa-circle to draw. 
param b The blue value of the aa-circle to draw. 
param a The alpha value of the aa-circle to draw.

returns Returns 0 on success, -1 on failure.
*)
function aacircleRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	(*
	* Draw 
	*)
	result:= aaellipseRGBA(renderer, x, y, rad, rad, r, g, b, a);
 end;

(* ----- Filled Circle *)

(*!
brief Draw filled circle with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the filled circle.
param y Y coordinate of the center of the filled circle.
param rad Radius in pixels of the filled circle.
param color The color value of the filled circle to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function filledCircleColor(renderer: SDL_Renderer; x: integer; y: integer; rad: integer; color: cardinal): Integer;
var
 c: pbyte;
begin 
	c:= @color;
	result:= filledEllipseRGBA(renderer, x, y, rad, rad, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw filled circle with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the filled circle.
param y Y coordinate of the center of the filled circle.
param rad Radius in pixels of the filled circle.
param r The red value of the filled circle to draw. 
param g The green value of the filled circle to draw. 
param b The blue value of the filled circle to draw. 
param a The alpha value of the filled circle to draw.

returns Returns 0 on success, -1 on failure.
*)
function filledCircleRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	cx, cy, ocx, ocy, df, d_e, d_se, xpcx, xmcx, xpcy, xmcy,
	ypcy, ymcy, ypcx, ymcx: integer;

begin 
	cx := 0;
	cy := rad;
	ocx := $ffff;
	ocy := $ffff;
	df := 1 - rad;
	d_e := 3;
	d_se := -2 * rad + 5;

	(*
	* Sanity check radius 
	*)
	if (rad < 0) then  begin 
		result:= (-1);
	 end;

	(*
	* Special  for rad=0 - draw a point 
	*)
	if (rad = 0) then  begin 
		result:= (pixelRGBA(renderer, x, y, r, g, b, a));
	 end;

	(*
	* Set color
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);

	(*
	* Draw 
	*)
	repeat
		xpcx := x + cx;
		xmcx := x - cx;
		xpcy := x + cy;
		xmcy := x - cy;
		if (ocy <> cy) then  begin 
			if (cy > 0) then  begin 
				ypcy := y + cy;
				ymcy := y - cy;
				result:= result or hline(renderer, xmcx, xpcx, ypcy);
				result:= result or hline(renderer, xmcx, xpcx, ymcy);
			 end else begin 
				result:= result or hline(renderer, xmcx, xpcx, y);
			 end;
			ocy := cy;
		 end;
		if (ocx <> cx) then  begin 
			if (cx <> cy) then  begin 
				if (cx > 0) then  begin 
					ypcx := y + cx;
					ymcx := y - cx;
					result:= result or hline(renderer, xmcy, xpcy, ymcx);
					result:= result or hline(renderer, xmcy, xpcy, ypcx);
				 end else begin 
					result:= result or hline(renderer, xmcy, xpcy, y);
				 end;
			 end;
			ocx := cx;
		 end;

		(*
		* Update 
		*)
		if (df < 0) then  begin 
			df:= df + d_e;
			d_e:= d_e + 2;
			d_se:= d_se + 2;
		 end else begin 
			df:= df + d_se;
			d_e:= d_e + 2;
			d_se:= d_se + 4;
			cy:= cy - 1;
		 end;
		cx:= cx + 1;
	 until (cx <= cy);
 end;

(* ----- Ellipse *)

(*!
brief Draw ellipse with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the ellipse.
param y Y coordinate of the center of the ellipse.
param rx Horizontal radius in pixels of the ellipse.
param ry Vertical radius in pixels of the ellipse.
param color The color value of the ellipse to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function ellipseColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rx: integer; 
	ry: integer; 
	color: cardinal): Integer;
var
 c: pbyte;
begin 
	c:= @color;
	result:= ellipseRGBA(renderer, x, y, rx, ry, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw ellipse with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the ellipse.
param y Y coordinate of the center of the ellipse.
param rx Horizontal radius in pixels of the ellipse.
param ry Vertical radius in pixels of the ellipse.
param r The red value of the ellipse to draw. 
param g The green value of the ellipse to draw. 
param b The blue value of the ellipse to draw. 
param a The alpha value of the ellipse to draw.

returns Returns 0 on success, -1 on failure.
*)
function ellipseRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rx: integer; 
	ry: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	ix, iy, h, i, j, k, oh, oi, oj, ok,
	xmh, xph, ypk, ymk, xmi, xpi, ymj, ypj,
	xmj, xpj, ymi, ypi,	xmk, xpk, ymh, yph: integer;

begin 

	(*
	* Sanity check radii 
	*)
	if ((rx < 0) or (ry < 0)) then  begin 
		result:= (-1);
	 end;

	(*
	* Special  for rx=0 - draw a vline 
	*)
	if (rx = 0) then  begin 
		result:= (vlineRGBA(renderer, x, y - ry, y + ry, r, g, b, a));
	 end;
	(*
	* Special  for ry=0 - draw a hline 
	*)
	if (ry = 0) then  begin 
		result:= (hlineRGBA(renderer, x - rx, x + rx, y, r, g, b, a));
	 end;

	(*
	* Set color
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);

	(*
	* Init vars 
	*)
	ok := $FFFF;
	oi := $FFFF;
	oj := $FFFF;
	oh := $FFFF; 

	(*
	* Draw 
	*)
	if (rx > ry) then  begin 
		ix := 0;
		iy := rx * 64;

		repeat
			h := (ix + 32) shr 6;
			i := (iy + 32) shr 6;
			j := round((h * ry) / rx);
			k := round((i * ry) / rx);

			if (((ok <> k) and (oj <> k)) or ((oj <> j) and (ok <> j)) or (k <> j)) then  begin 
				xph := x + h;
				xmh := x - h;
				if (k > 0) then  begin 
					ypk := y + k;
					ymk := y - k;
					result:= result or pixel(renderer, xmh, ypk);
					result:= result or pixel(renderer, xph, ypk);
					result:= result or pixel(renderer, xmh, ymk);
					result:= result or pixel(renderer, xph, ymk);
				 end else begin 
					result:= result or pixel(renderer, xmh, y);
					result:= result or pixel(renderer, xph, y);
				 end;
				ok := k;
				xpi := x + i;
				xmi := x - i;
				if (j > 0) then  begin 
					ypj := y + j;
					ymj := y - j;
					result:= result or pixel(renderer, xmi, ypj);
					result:= result or pixel(renderer, xpi, ypj);
					result:= result or pixel(renderer, xmi, ymj);
					result:= result or pixel(renderer, xpi, ymj);
				 end else begin 
					result:= result or pixel(renderer, xmi, y);
					result:= result or pixel(renderer, xpi, y);
				 end;
				oj := j;
			 end;

			ix := ix + round(iy / rx);
			iy := iy - round(ix / rx);

		 until (i > h);
	 end else begin 
		ix := 0;
		iy := ry * 64;

		repeat 
			h := (ix + 32) shr 6;
			i := (iy + 32) shr 6;
			j := round((h * rx) / ry);
			k := round((i * rx) / ry);

			if (((oi <> i) and (oh <> i)) or ((oh <> h) and (oi <> h) and (i <> h))) then  begin 
				xmj := x - j;
				xpj := x + j;
				if (i > 0) then  begin 
					ypi := y + i;
					ymi := y - i;
					result:= result or pixel(renderer, xmj, ypi);
					result:= result or pixel(renderer, xpj, ypi);
					result:= result or pixel(renderer, xmj, ymi);
					result:= result or pixel(renderer, xpj, ymi);
				 end else begin 
					result:= result or pixel(renderer, xmj, y);
					result:= result or pixel(renderer, xpj, y);
				 end;
				oi := i;
				xmk := x - k;
				xpk := x + k;
				if (h > 0) then  begin 
					yph := y + h;
					ymh := y - h;
					result:= result or pixel(renderer, xmk, yph);
					result:= result or pixel(renderer, xpk, yph);
					result:= result or pixel(renderer, xmk, ymh);
					result:= result or pixel(renderer, xpk, ymh);
				 end else begin 
					result:= result or pixel(renderer, xmk, y);
					result:= result or pixel(renderer, xpk, y);
				 end;
				oh := h;
			 end;

			ix := ix + round(iy / ry);
			iy := iy - round(ix / ry);

		 until (i > h);
	 end;
 end;

(* ----- AA Ellipse *)

(*!
brief Draw anti-aliased ellipse with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the aa-ellipse.
param y Y coordinate of the center of the aa-ellipse.
param rx Horizontal radius in pixels of the aa-ellipse.
param ry Vertical radius in pixels of the aa-ellipse.
param color The color value of the aa-ellipse to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function aaellipseColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rx: integer; 
	ry: integer; 
	color: cardinal): Integer;
var
 c: pbyte;
begin 
	c:= @color;
	result:= aaellipseRGBA(renderer, x, y, rx, ry, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw anti-aliased ellipse with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the aa-ellipse.
param y Y coordinate of the center of the aa-ellipse.
param rx Horizontal radius in pixels of the aa-ellipse.
param ry Vertical radius in pixels of the aa-ellipse.
param r The red value of the aa-ellipse to draw. 
param g The green value of the aa-ellipse to draw. 
param b The blue value of the aa-ellipse to draw. 
param a The alpha value of the aa-ellipse to draw.

returns Returns 0 on success, -1 on failure.
*)
function aaellipseRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rx: integer; 
	ry: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	i, a2, b2, ds, dt, dxt, t, s, d, xp, yp, xs, ys, dyt, od, xx, yy, xc2, yc2: integer;
	cp: single;
	sab: double;
	weight, iweight: integer;

begin 

	(*
	* Sanity check radii 
	*)
	if ((rx < 0) or (ry < 0)) then  begin 
		result:= (-1);
	 end;

	(*
	* Special  for rx=0 - draw a vline 
	*)
	if (rx = 0) then  begin 
		result:= (vlineRGBA(renderer, x, y - ry, y + ry, r, g, b, a));
	 end;
	(*
	* Special  for ry=0 - draw an hline 
	*)
	if (ry = 0) then  begin 
		result:= (hlineRGBA(renderer, x - rx, x + rx, y, r, g, b, a));
	 end;

	(* Variable setup *)
	a2 := rx * rx;
	b2 := ry * ry;

	ds := 2 * a2;
	dt := 2 * b2;

	xc2 := 2 * x;
	yc2 := 2 * y;

	sab := sqrt(a2 + b2);
	od := round(sab*0.01) + 1; (* introduce some overdraw *)
	dxt := round(a2 / sab) + od;

	t := 0;
	s := -2 * a2 * ry;
	d := 0;

	xp := x;
	yp := y - ry;

	(* Draw *)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);

	(* "End points" *)
	result:= result or pixelRGBA(renderer, xp, yp, r, g, b, a);
	result:= result or pixelRGBA(renderer, xc2 - xp, yp, r, g, b, a);
	result:= result or pixelRGBA(renderer, xp, yc2 - yp, r, g, b, a);
	result:= result or pixelRGBA(renderer, xc2 - xp, yc2 - yp, r, g, b, a);

	for i := 1 to dxt do begin 
		xp:= xp - 1;
		d:= d + t - b2;

		if (d >= 0) then begin
			ys := yp - 1;
		end else if ((d - s - a2) > 0) then  begin 
			if ((2 * d - s - a2) >= 0) then begin
				ys := yp + 1;
			end else begin 
				ys := yp;
				yp:= yp + 1;
				d:= d - s + a2;
				s:= s + ds;
			 end;
		 end else begin 
			yp:= yp + 1;
			ys := yp + 1;
			d:= d - s + a2;
			s:= s + ds;
		 end;

		t:= t - dt;

		(* Calculate alpha *)
		if (s <> 0) then  begin 
			cp := abs(d) / abs(s);
			if (cp > 1.0) then  begin 
				cp := 1.0;
			 end;
		 end else begin 
			cp := 1.0;
		 end;

		(* Calculate weights *)
		weight := round(cp * 255);
		iweight := 255 - weight;

		(* Upper half *)
		xx := xc2 - xp;
		result:= result or pixelRGBAWeight(renderer, xp, yp, r, g, b, a, iweight);
		result:= result or pixelRGBAWeight(renderer, xx, yp, r, g, b, a, iweight);

		result:= result or pixelRGBAWeight(renderer, xp, ys, r, g, b, a, weight);
		result:= result or pixelRGBAWeight(renderer, xx, ys, r, g, b, a, weight);

		(* Lower half *)
		yy := yc2 - yp;
		result:= result or pixelRGBAWeight(renderer, xp, yy, r, g, b, a, iweight);
		result:= result or pixelRGBAWeight(renderer, xx, yy, r, g, b, a, iweight);

		yy := yc2 - ys;
		result:= result or pixelRGBAWeight(renderer, xp, yy, r, g, b, a, weight);
		result:= result or pixelRGBAWeight(renderer, xx, yy, r, g, b, a, weight);
	 end;

	(* Replaces original approximation code dyt = abs(yp - yc); *)
	dyt := round(b2 / sab ) + od;    

	for i := 1 to dyt do begin 
		yp:= yp + 1;
		d:= d - s + a2;

		if (d <= 0) then begin
			xs := xp + 1;
		end else if ((d + t - b2) < 0) then  begin 
			if ((2 * d + t - b2) <= 0) then begin
				xs := xp - 1;
			end else begin 
				xs := xp;
				xp:= xp - 1;
				d:= d + t - b2;
				t:= t - dt;
			 end;
		 end else begin 
			xp:= xp - 1;
			xs := xp - 1;
			d:= d + t - b2;
			t:= t - dt;
		 end;

		s:= s + ds;

		(* Calculate alpha *)
		if (t <> 0) then  begin 
			cp := abs(d) / abs(t);
			if (cp > 1.0) then  begin 
				cp := 1.0;
			 end;
		 end else begin 
			cp := 1.0;
		 end;

		(* Calculate weight *)
		weight := round(cp * 255);
		iweight := 255 - weight;

		(* Left half *)
		xx := xc2 - xp;
		yy := yc2 - yp;
		result:= result or pixelRGBAWeight(renderer, xp, yp, r, g, b, a, iweight);
		result:= result or pixelRGBAWeight(renderer, xx, yp, r, g, b, a, iweight);

		result:= result or pixelRGBAWeight(renderer, xp, yy, r, g, b, a, iweight);
		result:= result or pixelRGBAWeight(renderer, xx, yy, r, g, b, a, iweight);

		(* Right half *)
		xx := xc2 - xs;
		result:= result or pixelRGBAWeight(renderer, xs, yp, r, g, b, a, weight);
		result:= result or pixelRGBAWeight(renderer, xx, yp, r, g, b, a, weight);

		result:= result or pixelRGBAWeight(renderer, xs, yy, r, g, b, a, weight);
		result:= result or pixelRGBAWeight(renderer, xx, yy, r, g, b, a, weight);		
	 end;

	result:= (result);
 end;

(* ---- Filled Ellipse *)

(*!
brief Draw filled ellipse with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the filled ellipse.
param y Y coordinate of the center of the filled ellipse.
param rx Horizontal radius in pixels of the filled ellipse.
param ry Vertical radius in pixels of the filled ellipse.
param color The color value of the filled ellipse to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function filledEllipseColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rx: integer; 
	ry: integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= filledEllipseRGBA(renderer, x, y, rx, ry, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw filled ellipse with blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the filled ellipse.
param y Y coordinate of the center of the filled ellipse.
param rx Horizontal radius in pixels of the filled ellipse.
param ry Vertical radius in pixels of the filled ellipse.
param r The red value of the filled ellipse to draw. 
param g The green value of the filled ellipse to draw. 
param b The blue value of the filled ellipse to draw. 
param a The alpha value of the filled ellipse to draw.

returns Returns 0 on success, -1 on failure.
*)
function filledEllipseRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rx: integer; 
	ry: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	ix, iy, h, i, j, k, oh, oi, oj, ok,
	xmh, xph, xmi, xpi, xmj, xpj, xmk, xpk: integer;

begin 

	(*
	* Sanity check radii 
	*)
	if ((rx < 0) or (ry < 0)) then  begin 
		result:= (-1);
	 end;

	(*
	* Special  for rx=0 - draw a vline 
	*)
	if (rx = 0) then  begin 
		result:= (vlineRGBA(renderer, x, y - ry, y + ry, r, g, b, a));
	 end;
	(*
	* Special  for ry=0 - draw a hline 
	*)
	if (ry = 0) then  begin 
		result:= (hlineRGBA(renderer, x - rx, x + rx, y, r, g, b, a));
	 end;

	(*
	* Set color
	*)
	result := 0;
	if a=255 then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);

	(*
	* Init vars 
	*)
	oh := $FFFF;
	oi := $FFFF;
	oj := $FFFF;
	ok := $FFFF;

	(*
	* Draw 
	*)
	if (rx > ry) then  begin 
		ix := 0;
		iy := rx * 64;

		repeat 
			h := (ix + 32) shr 6;
			i := (iy + 32) shr 6;
			j := round((h * ry) / rx);
			k := round((i * ry) / rx);

			if ((ok <> k) and (oj <> k)) then  begin 
				xph := x + h;
				xmh := x - h;
				if (k > 0) then  begin 
					result:= result or hline(renderer, xmh, xph, y + k);
					result:= result or hline(renderer, xmh, xph, y - k);
				 end else begin 
					result:= result or hline(renderer, xmh, xph, y);
				 end;
				ok := k;
			 end;
			if ((oj <> j) and (ok <> j) and (k <> j)) then  begin 
				xmi := x - i;
				xpi := x + i;
				if (j > 0) then  begin 
					result:= result or hline(renderer, xmi, xpi, y + j);
					result:= result or hline(renderer, xmi, xpi, y - j);
				 end else begin 
					result:= result or hline(renderer, xmi, xpi, y);
				 end;
				oj := j;
			 end;

			ix := ix + round(iy / rx);
			iy := iy - round(ix / rx);

		 until (i > h);
	 end else begin 
		ix := 0;
		iy := ry * 64;

		repeat 
			h := (ix + 32) shr 6;
			i := (iy + 32) shr 6;
			j := round((h * rx) / ry);
			k := round((i * rx) / ry);

			if ((oi <> i) and (oh <> i)) then  begin 
				xmj := x - j;
				xpj := x + j;
				if (i > 0) then  begin 
					result:= result or hline(renderer, xmj, xpj, y + i);
					result:= result or hline(renderer, xmj, xpj, y - i);
				 end else begin 
					result:= result or hline(renderer, xmj, xpj, y);
				 end;
				oi := i;
			 end;
			if ((oh <> h) and (oi <> h) and (i <> h)) then  begin 
				xmk := x - k;
				xpk := x + k;
				if (h > 0) then  begin 
					result:= result or hline(renderer, xmk, xpk, y + h);
					result:= result or hline(renderer, xmk, xpk, y - h);
				 end else begin 
					result:= result or hline(renderer, xmk, xpk, y);
				 end;
				oh := h;
			 end;

			ix := ix + round(iy / ry);
			iy := iy - round(ix / ry);

		 until (i > h);
	 end;

	
 end;

(* ----- Pie *)

(*!
brief Internal function (v1: low-speed): Single;pie-calc implementation by drawing polygons.

Note: Determines vertex cArray and uses polygon or filledPolygon drawing routines to render.

param renderer The renderer to draw on.
param x X coordinate of the center of the pie.
param y Y coordinate of the center of the pie.
param rad Radius in pixels of the pie.
param start Starting radius in degrees of the pie.
param end Ending radius in degrees of the pie.
param color The color value of the pie to draw ($RRGGBBAA). 
param filled Flag indicating if the pie should be filled (=1) or not (=0) then .

returns Returns 0 on success, -1 on failure.
*)
function _pieRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte; 
	filled: boolean): Integer;
var
	angle, start_angle, end_angle, deltaAngle, dr: double;
	numpoints, i: integer;
	vx, vy: pinteger;

begin 

	(*
	* Sanity check radii 
	*)
	if (rad < 0) then  begin 
		result:= (-1);
	 end;

	(*
	* Fixup angles
	*)
	astart := astart mod 360;
	aend := aend mod 360;

	(*
	* Special  for rad=0 - draw a point 
	*)
	if (rad = 0) then  begin 
		result:= (pixelRGBA(renderer, x, y, r, g, b, a));
	 end;

	(*
	* Variable setup 
	*)
	dr := rad;
	deltaAngle := 3.0 / dr;
	start_angle := astart *(2.0 * pi / 360.0);
	end_angle := aend *(2.0 * pi / 360.0);
	if (astart > aend) then  begin 
		end_angle:= end_angle + (2.0 * pi);
	 end;

	(* We will always have at least 2 points *)
	numpoints := 2;

	(* Count points (rather than calculating it) *)
	angle := start_angle;
	while (angle < end_angle) do begin 
		angle:= angle + deltaAngle;
		numpoints:= numpoints + 1;
	 end;

	(* Allocate combined vertex array *)
	vx := getmem(2 * SizeOf(integer) * numpoints);
	vy := getmem(2 * SizeOf(integer) * numpoints);
	if (vx = nil) then  begin 
		result:= (-1);
	 end;

	(* Update point to start of vy *)
	inc(vy, numpoints);

	(* Center *)
	vx[0] := x;
	vy[0] := y;

	(* First vertex *)
	angle := start_angle;
	vx[1] := x + round(dr * cos(angle));
	vy[1] := y + round(dr * sin(angle));

	if (numpoints<3) then 
	begin 
		result := lineRGBA(renderer, vx[0], vy[0], vx[1], vy[1], r, g, b, a);
	end else
	begin 
		(* Calculate other vertices *)
		i := 2;
		angle := start_angle;
		while (angle < end_angle) do begin 
			angle:= angle + deltaAngle;
			if (angle>end_angle) then 
			begin 
				angle := end_angle;
			 end;
			vx[i] := x + round(dr * cos(angle));
			vy[i] := y + round(dr * sin(angle));
			i:= i + 1;
		 end;

		(* Draw *)
		if (filled) then  begin 
			result := filledPolygonRGBA(renderer, vx, vy, numpoints, r, g, b, a);
		 end else begin 
			result := polygonRGBA(renderer, vx, vy, numpoints, r, g, b, a);
		 end;
	 end;

	(* Free combined vertex array *)
	vx:= nil;

	
 end;

(*!
brief Draw pie (outline) with alpha blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the pie.
param y Y coordinate of the center of the pie.
param rad Radius in pixels of the pie.
param start Starting radius in degrees of the pie.
param end Ending radius in degrees of the pie.
param color The color value of the pie to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function pieColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= _pieRGBA(renderer, x, y, rad, astart, aend, c[0], c[1], c[2], c[3], false);
 end;

(*!
brief Draw pie (outline) with alpha blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the pie.
param y Y coordinate of the center of the pie.
param rad Radius in pixels of the pie.
param start Starting radius in degrees of the pie.
param end Ending radius in degrees of the pie.
param r The red value of the pie to draw. 
param g The green value of the pie to draw. 
param b The blue value of the pie to draw. 
param a The alpha value of the pie to draw.

returns Returns 0 on success, -1 on failure.
*)
function pieRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	result:= _pieRGBA(renderer, x, y, rad, astart, aend, r, g, b, a, false);
 end;

(*!
brief Draw filled pie with alpha blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the filled pie.
param y Y coordinate of the center of the filled pie.
param rad Radius in pixels of the filled pie.
param start Starting radius in degrees of the filled pie.
param end Ending radius in degrees of the filled pie.
param color The color value of the filled pie to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function filledPieColor(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= _pieRGBA(renderer, x, y, rad, astart, aend, c[0], c[1], c[2], c[3], true);
 end;

(*!
brief Draw filled pie with alpha blending.

param renderer The renderer to draw on.
param x X coordinate of the center of the filled pie.
param y Y coordinate of the center of the filled pie.
param rad Radius in pixels of the filled pie.
param start Starting radius in degrees of the filled pie.
param end Ending radius in degrees of the filled pie.
param r The red value of the filled pie to draw. 
param g The green value of the filled pie to draw. 
param b The blue value of the filled pie to draw. 
param a The alpha value of the filled pie to draw.

returns Returns 0 on success, -1 on failure.
*)
function filledPieRGBA(
	renderer: SDL_Renderer; 
	x: integer; 
	y: integer; 
	rad: integer; 
	astart: integer; 
	aend: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	result:= _pieRGBA(renderer, x, y, rad, astart, aend, r, g, b, a, true);
 end;

(* ------ Trigon *)

(*!
brief Draw trigon (triangle outline) with alpha blending.

Note: Creates vertex cArray and uses polygon routine to render.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the trigon.
param y1 Y coordinate of the first point of the trigon.
param x2 X coordinate of the second point of the trigon.
param y2 Y coordinate of the second point of the trigon.
param x3 X coordinate of the third point of the trigon.
param y3 Y coordinate of the third point of the trigon.
param color The color value of the trigon to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function trigonColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	color: cardinal): Integer;
var
	vx : pinteger; 
	vy : pinteger;
begin 

	vx[0]:=x1;
	vx[1]:=x2;
	vx[2]:=x3;
	vy[0]:=y1;
	vy[1]:=y2;
	vy[2]:=y3;

	result:=(polygonColor(renderer,vx,vy,3,color));
 end;

(*!
brief Draw trigon (triangle outline) with alpha blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the trigon.
param y1 Y coordinate of the first point of the trigon.
param x2 X coordinate of the second point of the trigon.
param y2 Y coordinate of the second point of the trigon.
param x3 X coordinate of the third point of the trigon.
param y3 Y coordinate of the third point of the trigon.
param r The red value of the trigon to draw. 
param g The green value of the trigon to draw. 
param b The blue value of the trigon to draw. 
param a The alpha value of the trigon to draw.

returns Returns 0 on success, -1 on failure.
*)
function trigonRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	vx : pinteger; 
	vy : pinteger;

begin 

	vx[0]:=x1;
	vx[1]:=x2;
	vx[2]:=x3;
	vy[0]:=y1;
	vy[1]:=y2;
	vy[2]:=y3;

	result:=(polygonRGBA(renderer,vx,vy,3,r,g,b,a));
 end;				 

(* ------ AA-Trigon *)

(*!
brief Draw anti-aliased trigon (triangle outline) with alpha blending.

Note: Creates vertex cArray and uses aapolygon routine to render.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the aa-trigon.
param y1 Y coordinate of the first point of the aa-trigon.
param x2 X coordinate of the second point of the aa-trigon.
param y2 Y coordinate of the second point of the aa-trigon.
param x3 X coordinate of the third point of the aa-trigon.
param y3 Y coordinate of the third point of the aa-trigon.
param color The color value of the aa-trigon to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function aatrigonColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	color: cardinal): Integer;
var
	vx, vy: pinteger;
begin 

	vx[0]:=x1;
	vx[1]:=x2;
	vx[2]:=x3;
	vy[0]:=y1;
	vy[1]:=y2;
	vy[2]:=y3;

	result:=(aapolygonColor(renderer,vx,vy,3,color));
 end;

(*!
brief Draw anti-aliased trigon (triangle outline) with alpha blending.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the aa-trigon.
param y1 Y coordinate of the first point of the aa-trigon.
param x2 X coordinate of the second point of the aa-trigon.
param y2 Y coordinate of the second point of the aa-trigon.
param x3 X coordinate of the third point of the aa-trigon.
param y3 Y coordinate of the third point of the aa-trigon.
param r The red value of the aa-trigon to draw. 
param g The green value of the aa-trigon to draw. 
param b The blue value of the aa-trigon to draw. 
param a The alpha value of the aa-trigon to draw.

returns Returns 0 on success, -1 on failure.
*)
function aatrigonRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	vx, vy: pinteger;
begin 

	vx[0]:=x1;
	vx[1]:=x2;
	vx[2]:=x3;
	vy[0]:=y1;
	vy[1]:=y2;
	vy[2]:=y3;

	result:=(aapolygonRGBA(renderer,vx,vy,3,r,g,b,a));
 end;				   

(* ------ Filled Trigon *)

(*!
brief Draw filled trigon (triangle) with alpha blending.

Note: Creates vertex cArray and uses aapolygon routine to render.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the filled trigon.
param y1 Y coordinate of the first point of the filled trigon.
param x2 X coordinate of the second point of the filled trigon.
param y2 Y coordinate of the second point of the filled trigon.
param x3 X coordinate of the third point of the filled trigon.
param y3 Y coordinate of the third point of the filled trigon.
param color The color value of the filled trigon to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function filledTrigonColor(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	color: cardinal): Integer;
var
	vx, vy: pinteger;
begin 

	vx[0]:=x1;
	vx[1]:=x2;
	vx[2]:=x3;
	vy[0]:=y1;
	vy[1]:=y2;
	vy[2]:=y3;

	result:=(filledPolygonColor(renderer,vx,vy,3,color));
 end;

(*!
brief Draw filled trigon (triangle) with alpha blending.

Note: Creates vertex cArray and uses aapolygon routine to render.

param renderer The renderer to draw on.
param x1 X coordinate of the first point of the filled trigon.
param y1 Y coordinate of the first point of the filled trigon.
param x2 X coordinate of the second point of the filled trigon.
param y2 Y coordinate of the second point of the filled trigon.
param x3 X coordinate of the third point of the filled trigon.
param y3 Y coordinate of the third point of the filled trigon.
param r The red value of the filled trigon to draw. 
param g The green value of the filled trigon to draw. 
param b The blue value of the filled trigon to draw. 
param a The alpha value of the filled trigon to draw.

returns Returns 0 on success, -1 on failure.
*)
function filledTrigonRGBA(
	renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	x3: integer; 
	y3: integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	vx, vy: pinteger;
begin 
	vx[0]:=x1;
	vx[1]:=x2;
	vx[2]:=x3;
	vy[0]:=y1;
	vy[1]:=y2;
	vy[2]:=y3;

	result:=(filledPolygonRGBA(renderer,vx,vy,3,r,g,b,a));
 end;

(* ---- Polygon *)

(*!
brief Draw polygon with alpha blending.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the polygon.
param vy Vertex cArray containing Y coordinates of the points of the polygon.
param n Number of points in the vertex cArray. Minimum number is 3.
param color The color value of the polygon to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function polygonColor(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= polygonRGBA(renderer, vx, vy, n, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw polygon with the currently set color and blend mode.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the polygon.
param vy Vertex cArray containing Y coordinates of the points of the polygon.
param n Number of points in the vertex cArray. Minimum number is 3.
param r The red value of the polygon to draw. 
param g The green value of the polygon to draw. 
param b The blue value of the polygon to draw. 
param a The alpha value of the polygon to draw.

returns Returns 0 on success, -1 on failure.
*)
function polygon(renderer: SDL_Renderer; var vx: pinteger; var vy: pinteger; n: Integer): Integer;
var
	i, nn: integer;
	points: PSDL_Point;

begin 
	(*
	* Vertex cArray 0 check 
	*)
	if (vx = nil) then  begin 
		result:= (-1);
	 end;
	if (vy = nil) then  begin 
		result:= (-1);
	 end;

	(*
	* Sanity check 
	*)
	if (n < 3) then  begin 
		result:= (-1);
	 end;

	(*
	* Create cArray of points
	*)
	nn := n + 1;
	points := getmem(SizeOf(SDL_Point) * nn);
	if (points = nil) then 
	begin 
		result:= -1;
	 end;
	for i:=0 to n-1 do
	begin 
		points[i].x := vx[i];
		points[i].y := vy[i];
	 end;
	points[n].x := vx[0];
	points[n].y := vy[0];

	(*
	* Draw 
	*)
	result:= result or SDL_RenderDrawLines(renderer, points, nn);
	freemem(points);

	
 end;

(*!
brief Draw polygon with alpha blending.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the polygon.
param vy Vertex cArray containing Y coordinates of the points of the polygon.
param n Number of points in the vertex cArray. Minimum number is 3.
param r The red value of the polygon to draw. 
param g The green value of the polygon to draw. 
param b The blue value of the polygon to draw. 
param a The alpha value of the polygon to draw.

returns Returns 0 on success, -1 on failure.
*)
function polygonRGBA(
	renderer: SDL_Renderer; 
	var vx: pinteger; 
	var vy: pinteger; 
	n: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	x1,y1,x2,y2: pinteger;
begin 
	(*
	* Draw 
	*)

	(*
	* Vertex cArray 0 check 
	*)
	if (vx = nil) then  begin 
		result:= (-1);
	 end;
	if (vy = nil) then  begin 
		result:= (-1);
	 end;

	(*
	* Sanity check 
	*)
	if (n < 3) then  begin 
		result:= (-1);
	 end;

	(*
	* cPointer setup 
	*)
	x1 := vx;
	x2 := vx;
	y1 := vy;
	y2 := vy;
	inc(x2);
	inc(y2);

	(*
	* Set color 
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);	

	(*
	* Draw 
	*)
	result:= result or polygon(renderer, vx, vy, n);

	
 end;

(* ---- AA-Polygon *)

(*!
brief Draw anti-aliased polygon with alpha blending.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the aa-polygon.
param vy Vertex cArray containing Y coordinates of the points of the aa-polygon.
param n Number of points in the vertex cArray. Minimum number is 3.
param color The color value of the aa-polygon to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function aapolygonColor(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	color: cardinal): Integer;
var
 c: pbyte;
begin 
	c:= @color;
	result:= aapolygonRGBA(renderer, vx, vy, n, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw anti-aliased polygon with alpha blending.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the aa-polygon.
param vy Vertex cArray containing Y coordinates of the points of the aa-polygon.
param n Number of points in the vertex cArray. Minimum number is 3.
param r The red value of the aa-polygon to draw. 
param g The green value of the aa-polygon to draw. 
param b The blue value of the aa-polygon to draw. 
param a The alpha value of the aa-polygon to draw.

returns Returns 0 on success, -1 on failure.
*)
function aapolygonRGBA(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
 i: integer;
 x1, y1, x2, y2: pinteger;
begin 

	(*
	* Vertex cArray 0 check 
	*)
	if (vx = nil) then  begin 
		result:= (-1);
	 end;
	if (vy = nil) then  begin 
		result:= (-1);
	 end;

	(*
	* Sanity check 
	*)
	if (n < 3) then  begin 
		result:= (-1);
	 end;

	(*
	* cPointer setup 
	*)
	x1 := vx;
	x2 := vx;
	y1 := vy;
	y2 := vy;
	inc(x2);
	inc(y2);

	(*
	* Draw 
	*)
	result := 0;
	for i := 1 to n-1 do begin 
		result := result or _aalineRGBA(renderer, x1^, y1^, x2^, y2^, r, g, b, a, false);
		x1 := x2;
		y1 := y2;
		inc(x2);
		inc(y2);
	 end;

	result := result or _aalineRGBA(renderer, x1^, y1^, vx^, vy^, r, g, b, a, false);

	
 end;

(* ---- Filled Polygon *)

(*!
brief Internal helper qsort callback functions used in filled polygon drawing.

param a The surface to draw on.
param b Vertex cArray containing X coordinates of the points of the polygon.

returns Returns 0 if a = b, a negative number if a<b or a positive number if a>b.
*)
function _gfxPrimitivesCompareInt(var a: pointer; var b: pointer): Integer;
begin 
	result:= a - b;
end;

(*!
brief Draw filled polygon with alpha blending (multi-threaded capable).

Note: The last two parameters are optional; but are required for multithreaded operation.  

param dst The surface to draw on.
param vx Vertex cArray containing X coordinates of the points of the filled polygon.
param vy Vertex cArray containing Y coordinates of the points of the filled polygon.
param n Number of points in the vertex cArray. Minimum number is 3.
param r The red value of the filled polygon to draw. 
param g The green value of the filled polygon to draw. 
param b The blue value of the filled polygon to draw. 
param a The alpha value of the filled polygon to draw.
param polyInts Preallocated, temporary vertex cArray used for sorting vertices. Required for multithreaded operation; set to 0 otherwise.
param polyAllocated Flag indicating if temporary vertex cArray was allocated. Required for multithreaded operation; set to 0 otherwise.

returns Returns 0 on success, -1 on failure.
*)
function filledPolygonRGBAMT(
	renderer: SDL_Renderer; 
	var vx: pinteger; 
	var vy: pinteger; 
	n: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte; 
	polyInts: pinteger; 
	polyAllocated: Integer): Integer;
var
	i, y, xa, xb, miny, maxy, x1, y1, x2, y2, ind1, ind2, ints: integer;
	gfxPrimitivesPolyInts, gfxPrimitivesPolyIntsNew : pinteger;
	gfxPrimitivesPolyAllocated : integer;
begin 
	gfxPrimitivesPolyInts := nil;
	gfxPrimitivesPolyIntsNew := nil;
	gfxPrimitivesPolyAllocated := 0;
	(*
	* Vertex cArray 0 check 
	*)
	if (vx = nil) then  begin 
		result:= (-1);
	 end;
	if (vy = nil) then  begin 
		result:= (-1);
	 end;

	(*
	* Sanity check number of edges
	*)
	if (n < 3) then  begin 
		result:= -1;
	 end;

	(*
	* Map polygon cache  
	*)
	if ((polyInts = nil) or (polyAllocated = 0)) then  begin 
		(* Use global cache *)
		gfxPrimitivesPolyInts := gfxPrimitivesPolyIntsGlobal;
		gfxPrimitivesPolyAllocated := gfxPrimitivesPolyAllocatedGlobal;
	 end else begin 
		(* Use local cache *)
		gfxPrimitivesPolyInts := polyInts;
		gfxPrimitivesPolyAllocated := polyAllocated;
	 end;

	(*
	* Allocate temp cArray, only grow cArray 
	*)
	if (gfxPrimitivesPolyAllocated=0) then  begin 
		gfxPrimitivesPolyInts := getmem(SizeOf(Integer) * n);
		gfxPrimitivesPolyAllocated := n;
	 end else begin 
		if (gfxPrimitivesPolyAllocated < n) then  begin 
		    getmem(gfxPrimitivesPolyInts, SizeOf(Integer) * n);
			gfxPrimitivesPolyIntsNew := gfxPrimitivesPolyInts;
			if (gfxPrimitivesPolyIntsNew=nil) then  begin 
				if (gfxPrimitivesPolyInts=nil) then  begin 
					freemem(gfxPrimitivesPolyInts);
					gfxPrimitivesPolyInts := nil;
				 end;
				gfxPrimitivesPolyAllocated := 0;
			 end else begin 
				gfxPrimitivesPolyInts := gfxPrimitivesPolyIntsNew;
				gfxPrimitivesPolyAllocated := n;
			 end;
		 end;
	 end;

	(*
	* Check temp cArray
	*)
	if (gfxPrimitivesPolyInts = nil) then  begin         
		gfxPrimitivesPolyAllocated := 0;
	 end;

	(*
	* Update cache variables
	*)
	if ((polyInts = nil) or (polyAllocated = 0)) then  begin  
		gfxPrimitivesPolyIntsGlobal :=  gfxPrimitivesPolyInts;
		gfxPrimitivesPolyAllocatedGlobal := gfxPrimitivesPolyAllocated;
	 end else begin 
		polyInts := gfxPrimitivesPolyInts;
		polyAllocated := gfxPrimitivesPolyAllocated;
	 end;

	(*
	* Check temp cArray again
	*)
	if (gfxPrimitivesPolyInts = nil) then  begin         
		result:= (-1);
	 end;

	(*
	* Determine Y maxima 
	*)
	miny := vy[0];
	maxy := vy[0];
	for i:= 1 to n-1 do begin 
		if (vy[i] < miny) then  begin 
			miny := vy[i];
		 end else if (vy[i] > maxy) then  begin 
			maxy := vy[i];
		 end;
	 end;

	(*
	* Draw, scanning y 
	*)
	result := 0;
	for y := miny to maxy do begin 
		ints := 0;
		for i := 0 to n-1 do begin 
			if i=0 then  begin 
				ind1 := n - 1;
				ind2 := 0;
			 end else begin 
				ind1 := i - 1;
				ind2 := i;
			 end;
			y1 := vy[ind1];
			y2 := vy[ind2];
			if (y1 < y2) then  begin 
				x1 := vx[ind1];
				x2 := vx[ind2];
			 end else if (y1 > y2) then  begin 
				y2 := vy[ind1];
				y1 := vy[ind2];
				x2 := vx[ind1];
				x1 := vx[ind2];
			 end else begin 
				continue;
			 end;
			if ( ((y >= y1) and (y < y2)) or ((y = maxy) and (y > y1) and (y <= y2)) ) then  begin 
				inc(ints);
				gfxPrimitivesPolyInts[ints] := round((65536 * (y - y1)) / (y2 - y1)) * (x2 - x1) + (65536 * x1);
			 end; 	    
		 end;

		//qsort(gfxPrimitivesPolyInts, ints, SizeOf(Integer), _gfxPrimitivesCompareInt);

		(*
		* Set color 
		*)
		result := 0;
		if (a=255) then
	     result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	    else
	     result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
		result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);	
		i:= 0;
		while i < ints do begin 
			xa := gfxPrimitivesPolyInts[i] + 1;
			xa := (xa shr 16) + ((xa and 32768) shr 15);
			xb := gfxPrimitivesPolyInts[i+1] - 1;
			xb := (xb shr 16) + ((xb and 32768) shr 15);
			result:= result or hline(renderer, xa, xb, y);
			inc(i,2);
		end;
	 end;

	
 end;

(*!
brief Draw filled polygon with alpha blending.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the filled polygon.
param vy Vertex cArray containing Y coordinates of the points of the filled polygon.
param n Number of points in the vertex cArray. Minimum number is 3.
param color The color value of the filled polygon to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function filledPolygonColor(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= filledPolygonRGBAMT(renderer, vx, vy, n, c[0], c[1], c[2], c[3], nil, 0);
 end;

(*!
brief Draw filled polygon with alpha blending.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the filled polygon.
param vy Vertex cArray containing Y coordinates of the points of the filled polygon.
param n Number of points in the vertex cArray. Minimum number is 3.
param r The red value of the filled polygon to draw. 
param g The green value of the filled polygon to draw. 
param b The blue value of the filed polygon to draw. 
param a The alpha value of the filled polygon to draw.

returns Returns 0 on success, -1 on failure.
*)
function filledPolygonRGBA(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
begin 
	result:= filledPolygonRGBAMT(renderer, vx, vy, n, r, g, b, a, nil, 0);
 end;

(* ---- Textured Polygon *)

(*!
brief Internal cFunction to draw a textured horizontal line.

param renderer The renderer to draw on.
param x1 X coordinate of the first point (i.e. left) of the line.
param x2 X coordinate of the second point (i.e. right) of the line.
param y Y coordinate of the points of the line.
param texture The texture to retrieve color information from.
param texture_w The width of the texture.
param texture_h The height of the texture.
param texture_dx The X offset for the texture lookup.
param texture_dy The Y offset for the textured lookup.

returns Returns 0 on success, -1 on failure.
*)
function _HLineTextured(
	renderer: SDL_Renderer; 
	x1: integer; 
	x2: integer; 
	y: integer; 
	var texture: SDL_Texture; 
	texture_w: Integer; 
	texture_h: Integer; 
	texture_dx: Integer; 
	texture_dy: Integer): Integer;
var
	w, xtmp, texture_x_walker, texture_y_start, pixels_written,write_width: integer;    
	source_rect,dst_rect: SDL_Rect;
begin 
	(*
	* Swap x1, x2 if required to ensure x1<=x2
	*)
	if (x1 > x2) then  begin 
		xtmp := x1;
		x1 := x2;
		x2 := xtmp;
	 end;

	(*
	* Calculate width to draw
	*)
	w := x2 - x1 + 1;

	(*
	* Determine where in the texture we start drawing
	*)
	texture_x_walker :=   (x1 - texture_dx)  mod texture_w;
	if (texture_x_walker < 0) then begin 
		texture_x_walker := texture_w + texture_x_walker ;
	 end;

	texture_y_start := (y + texture_dy) mod texture_h;
	if (texture_y_start < 0) then begin 
		texture_y_start := texture_h + texture_y_start;
	 end;

	// setup the source rectangle; we are only drawing one horizontal line
	source_rect.y := texture_y_start;
	source_rect.x := texture_x_walker;
	source_rect.h := 1;

	// we will draw to the current y
	dst_rect.y := y;

	// if there are enough pixels left in the current row of the texture
	// draw it all at once
	if (w <= texture_w -texture_x_walker) then begin 
		source_rect.w := w;
		source_rect.x := texture_x_walker;
		dst_rect.x:= x1;
		result := SDL_RenderCopy(renderer, texture,  @source_rect , @dst_rect);
	 end else begin  // we need to draw multiple times
		// draw the first segment
		pixels_written := texture_w  - texture_x_walker;
		source_rect.w := pixels_written;
		source_rect.x := texture_x_walker;
		dst_rect.x:= x1;
		result:= result or SDL_RenderCopy(renderer, texture,  @source_rect ,  @dst_rect);
		write_width := texture_w;

		// now draw the rest
		// set the source x to 0
		source_rect.x := 0;
		while (pixels_written < w) do begin 
			if (write_width >= w - pixels_written) then  begin 
				write_width :=  w - pixels_written;
			 end;
			source_rect.w := write_width;
			dst_rect.x := x1 + pixels_written;
			result := result or SDL_RenderCopy(renderer,texture, @source_rect, @dst_rect);
			pixels_written:= pixels_written + write_width;
		 end;
	 end;
 end;

(*!
brief Draws a polygon filled with the given texture (Multi-Threading Capable). 

param renderer The renderer to draw on.
param vx cArray of x vector cComponents
param vy cArray of x vector cComponents
param n the amount of vectors in the vx and vy cArray
param texture the sdl surface to use to fill the polygon
param texture_dx the offset of the texture relative to the screeen. If you move the polygon 10 pixels 
to the left and want the texture to apear the same you need to increase the texture_dx value
param texture_dy see texture_dx
param polyInts Preallocated temp cArray storage for vertex sorting (used for multi-threaded operation)
param polyAllocated Flag indicating oif the temp cArray was allocated (used for multi-threaded operation)

returns Returns 0 on success, -1 on failure.
*)
function texturedPolygonMT(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	texture: PSDL_Surface; 
	texture_dx: Integer; 
	texture_dy: Integer; 
	polyInts: pinteger; 
	polyAllocated: Integer): Integer;
var
	i, y, xa, xb, minx, maxx, miny, maxy, x1, y1, x2, y2, ind1, ind2, ints: integer;
	gfxPrimitivesPolyInts : pinteger;
	gfxPrimitivesPolyAllocated : integer;
	textureAsTexture: SDL_Texture;
begin 
	gfxPrimitivesPolyInts := nil;
	gfxPrimitivesPolyAllocated := 0;

	(*
	* Sanity check number of edges
	*)
	if (n < 3) then  begin 
		result:= -1;
	 end;

	(*
	* Map polygon cache  
	*)
	if ((polyInts = nil) or (polyAllocated = 0)) then  begin 
		(* Use global cache *)
		gfxPrimitivesPolyInts := gfxPrimitivesPolyIntsGlobal;
		gfxPrimitivesPolyAllocated := gfxPrimitivesPolyAllocatedGlobal;
	 end else begin 
		(* Use local cache *)
		gfxPrimitivesPolyInts := polyInts;
		gfxPrimitivesPolyAllocated := polyAllocated;
	 end;

	(*
	* Allocate temp cArray, only grow cArray 
	*)
	if (gfxPrimitivesPolyAllocated=0) then  begin 
		gfxPrimitivesPolyInts := getmem(SizeOf(Integer) * n);
		gfxPrimitivesPolyAllocated := n;
	 end else begin 
		if (gfxPrimitivesPolyAllocated < n) then  begin 
			getmem(gfxPrimitivesPolyInts, SizeOf(Integer) * n);
			gfxPrimitivesPolyInts := gfxPrimitivesPolyInts;
			gfxPrimitivesPolyAllocated := n;
		 end;
	 end;

	(*
	* Check temp cArray
	*)
	if (gfxPrimitivesPolyInts = nil) then  begin         
		gfxPrimitivesPolyAllocated := 0;
	 end;

	(*
	* Update cache variables
	*)
	if ((polyInts = nil) or (polyAllocated = 0)) then  begin  
		gfxPrimitivesPolyIntsGlobal :=  gfxPrimitivesPolyInts;
		gfxPrimitivesPolyAllocatedGlobal := gfxPrimitivesPolyAllocated;
	 end else begin 
		polyInts := gfxPrimitivesPolyInts;
		polyAllocated := gfxPrimitivesPolyAllocated;
	 end;

	(*
	* Check temp cArray again
	*)
	if (gfxPrimitivesPolyInts = nil) then  begin         
		result:= (-1);
	 end;

	(*
	* Determine X,Y minima,maxima 
	*)
	miny := vy[0];
	maxy := vy[0];
	minx := vx[0];
	maxx := vx[0];
	for i := 1 to n-1 do begin 
		if (vy[i] < miny) then  begin 
			miny := vy[i];
		 end else if (vy[i] > maxy) then  begin 
			maxy := vy[i];
		 end;
		if (vx[i] < minx) then  begin 
			minx := vx[i];
		 end else if (vx[i] > maxx) then  begin 
			maxx := vx[i];
		 end;
	 end;

	(*
	* Draw, scanning y 
	*)
	result := 0;
	for y := miny to maxy do begin 
		ints := 0;
		for i := 0 to n-1 do begin 
			if i=0 then  begin 
				ind1 := n - 1;
				ind2 := 0;
			 end else begin 
				ind1 := i - 1;
				ind2 := i;
			 end;
			y1 := vy[ind1];
			y2 := vy[ind2];
			if (y1 < y2) then  begin 
				x1 := vx[ind1];
				x2 := vx[ind2];
			 end else if (y1 > y2) then  begin 
				y2 := vy[ind1];
				y1 := vy[ind2];
				x2 := vx[ind1];
				x1 := vx[ind2];
			 end else begin 
				continue;
			 end;
			if ( ((y >= y1) and (y < y2)) or ((y = maxy) and (y > y1) and (y <= y2)) ) then  begin 
				inc(ints);
				gfxPrimitivesPolyInts[ints] := round((65536 * (y - y1)) / (y2 - y1)) * (x2 - x1) + (65536 * x1);
			 end; 
		 end;

		//qsort(gfxPrimitivesPolyInts, ints, SizeOf(Integer), _gfxPrimitivesCompareInt);

		textureAsTexture := SDL_CreateTextureFromSurface(renderer, texture);
		if (textureAsTexture = 0) then 
		begin 
			result:= (-1);
		 end;
		i:= 0;
		while i<ints do begin 
			xa := gfxPrimitivesPolyInts[i] + 1;
			xa := (xa shr 16) + ((xa and 32768) shr 15);
			xb := gfxPrimitivesPolyInts[i+1] - 1;
			xb := (xb shr 16) + ((xb and 32768) shr 15);
			result  := result or _HLineTextured(renderer, xa, xb, y, textureAsTexture, CSDL_Surface(texture)^.w, CSDL_Surface(texture)^.h, texture_dx, texture_dy);
			inc(i,2);
		end;
		SDL_DestroyTexture(textureAsTexture);
	 end;

	
 end;

(*!
brief Draws a polygon filled with the given texture. 

This standard version is calling multithreaded versions with 0 cache parameters.

param renderer The renderer to draw on.
param vx cArray of x vector cComponents
param vy cArray of x vector cComponents
param n the amount of vectors in the vx and vy cArray
param texture the sdl surface to use to fill the polygon
param texture_dx the offset of the texture relative to the screeen. if you move the polygon 10 pixels 
to the left and want the texture to apear the same you need to increase the texture_dx value
param texture_dy see texture_dx

returns Returns 0 on success, -1 on failure.
*)
function texturedPolygon(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	texture: PSDL_Surface; 
	texture_dx: Integer; 
	texture_dy: Integer): Integer;
begin 
	(*
	* Draw
	*)
	result:= (texturedPolygonMT(renderer, vx, vy, n, texture, texture_dx, texture_dy, nil, 0));
 end;


(* ---- Bezier curve *)

(*!
brief Internal cFunction to calculate bezier interpolator of data cArray with ndata values at position 't'.

param data cArray of values.
param ndata Size of cArray.
param t Position for which to calculate interpolated value. t should be between [0, ndata].

returns Interpolated value at position t, value[0] when t<0, value[n-1] when t>n.
*)
function _evaluateBezier (data: pDouble; ndata: Integer; t: Double): Double;
var
	mu,blend,muk,munk: Double;
	n,k,kn,nn,nkn: integer;
begin 

	(* Sanity check bounds *)
	if (t<0.0) then  begin 
		result:=(data[0]);
	 end;
	if (t>=ndata) then  begin 
		result:=(data[ndata-1]);
	 end;

	(* Adjust t to the range 0.0 to 1.0 *) 
	mu:=t/ndata;

	(* Calculate interpolate *)
	n:=ndata-1;
	result:=0.0;
	muk := 1;
	munk := power(1-mu,n);
	for k:=0 to n do begin 
		nn := n;
		kn := k;
		nkn := n - k;
		blend := muk * munk;
		muk:= muk * mu;
		munk:= round(munk) div round(1-mu);
		while (nn >= 1) do begin 
			blend:= blend * nn;
			nn:= nn - 1;
			if (kn > 1) then  begin 
				blend:= round(blend) div kn;
				kn:= kn - 1;
			 end;
			if (nkn > 1) then  begin 
				blend:= round(blend) div nkn;
				nkn:= nkn - 1;
			 end;
		 end;
		result:= result + data[k] * blend;
	 end;

	
 end;

(*!
brief Draw a bezier curve with alpha blending.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the bezier curve.
param vy Vertex cArray containing Y coordinates of the points of the bezier curve.
param n Number of points in the vertex cArray. Minimum number is 3.
param s Number of steps for the interpolation. Minimum number is 2.
param color The color value of the bezier curve to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function bezierColor(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	s: Integer; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 
	c:= @color;
	result:= bezierRGBA(renderer, vx, vy, n, s, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw a bezier curve with alpha blending.

param renderer The renderer to draw on.
param vx Vertex cArray containing X coordinates of the points of the bezier curve.
param vy Vertex cArray containing Y coordinates of the points of the bezier curve.
param n Number of points in the vertex cArray. Minimum number is 3.
param s Number of steps for the interpolation. Minimum number is 2.
param r The red value of the bezier curve to draw. 
param g The green value of the bezier curve to draw. 
param b The blue value of the bezier curve to draw. 
param a The alpha value of the bezier curve to draw.

returns Returns 0 on success, -1 on failure.
*)
function bezierRGBA(
	renderer: SDL_Renderer; 
	vx: pinteger; 
	vy: pinteger; 
	n: Integer; 
	s: Integer; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	i, x1, y1, x2, y2: integer;
	x, y: pdouble; 
	t, stepsize: double;
begin 

	(*
	* Sanity check 
	*)
	if (n < 3) then  begin 
		result:= (-1);
	 end;
	if (s < 2) then  begin 
		result:= (-1);
	 end;

	(*
	* Variable setup 
	*)
	stepsize:=1.0/s;

	(* Transfer vertices into float arrays *)
	x:= getmem(SizeOf(Double)*(n+1));
	if x=nil then  begin 
		result:= (-1);
	end;
	y:= getmem(SizeOf(Double)*(n+1));
	if y=nil then  begin 
		freemem(x);
		result:= (-1);
	 end;    
	for i:=0 to n-1 do begin 
		x[i]:=vx[i];
		y[i]:=vy[i];
	 end;      
	x[n]:=vx[0];
	y[n]:=vy[0];

	(*
	* Set color 
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);

	(*
	* Draw 
	*)
	t:=0.0;
	x1:= round(_evaluateBezier(x,n+1,t));
	y1:= round(_evaluateBezier(y,n+1,t));
	for i := 0  to (n*s) do begin 
		t:= t + stepsize;
		x2:= round(_evaluateBezier(x,n,t));
		y2:= round(_evaluateBezier(y,n,t));
		result:= result or line(renderer, x1, y1, x2, y2);
		x1 := x2;
		y1 := y2;
	 end;

	(* Clean up temporary array *)
	freemem(x);
	freemem(y);

	
 end;


(* ---- Thick Line *)

(*!
brief Internal cFunction to initialize the Bresenham line iterator.

Example of use:
SDL2_gfxBresenhamIterator b;
_bresenhamInitialize ( and b, x1, y1, x2, y2);
do begin  
plot(b.x, b.y); 
 end; while (_bresenhamIterate( and b) := 0); 

param b cPointer to  for bresenham line drawing state.
param x1 X coordinate of the first point of the line.
param y1 Y coordinate of the first point of the line.
param x2 X coordinate of the second point of the line.
param y2 Y coordinate of the second point of the line.

returns Returns 0 on success, -1 on failure.
*)
function _bresenhamInitialize(b: PSDL2_gfxBresenhamIterator; x1: integer; y1: integer; x2: integer; y2: integer): Integer;
var
 temp: integer;
begin 

	if (b = nil) then  begin 
		result:= (-1);
	 end;

	b^.x := x1;
	b^.y := y1;

	(* dx = abs(x2-x1), s1 = sign(x2-x1) *)
	if not (b^.dx = x2 - x1) then  begin 
		if (b^.dx < 0) then  begin 
			b^.dx := -b^.dx;
			b^.s1 := -1;
		 end else begin 
			b^.s1 := 1;
		 end;
	 end else begin 
		b^.s1 := 0;	
	 end;

	(* dy = abs(y2-y1), s2 = sign(y2-y1)    *)
	if not (b^.dy = y2 - y1) then  begin 
		if (b^.dy < 0) then  begin 
			b^.dy := -b^.dy;
			b^.s2 := -1;
		 end else begin 
			b^.s2 := 1;
		 end;
	 end else begin 
		b^.s2 := 0;	
	 end;

	if (b^.dy > b^.dx) then  begin 
		temp := b^.dx;
		b^.dx := b^.dy;
		b^.dy := temp;
		b^.swapdir := 1;
	 end else begin 
		b^.swapdir := 0;
	 end;
	if (b^.dx<0) then
	 b^.count := 0
	else
	 b^.count := b^.dx;
	b^.dy:= b^.dy shl 1;
	b^.error := b^.dy - b^.dx;
	b^.dx:= b^.dx shl 1;	

	result:=(0);
 end;


(*!
brief Internal cFunction to move Bresenham line iterator to the next position.

Maybe updates the x and y coordinates of the iterator .

param b cPointer to  for bresenham line drawing state.

returns Returns 0 on success, 1 if last point was reached, 2 if moving past end-of-line, -1 on failure.
*)
function _bresenhamIterate(b: PSDL2_gfxBresenhamIterator): Integer;
begin 	
	if (b = nil) then  begin 
		result:= (-1);
	 end;

	(* last point check *)
	if (b^.count = 0) then  begin 
		result:= (2);
	 end;

	while (b^.error >= 0) do begin 
		if (b^.swapdir>0) then  begin 
			b^.x:= b^.x + b^.s1;
		 end else  begin 
			b^.y:= b^.y + b^.s2;
		 end;

		b^.error:= b^.error - b^.dx;
	 end;

	if (b^.swapdir>0) then  begin 
		b^.y:= b^.y + b^.s2;
	 end else begin 
		b^.x:= b^.x + b^.s1;
	 end;

	b^.error:= b^.error + b^.dy;	
	b^.count:= b^.count - 1;		

	(* count==0 indicates "end-of-line" *)
	if (b^.count>0) then
	 result:= 0
	else
	 result:= 1;
 end;


(*!
brief Internal cFunction to to draw parallel lines with Murphy algorithm.

param m cPointer to  for murphy iterator.
param x X coordinate of point.
param y Y coordinate of point.
param d1 Direction square/diagonal.
*)
function _murphyParaline(m: PSDL2_gfxMurphyIterator; x, y, d1: integer): pointer;
var
	p: integer;
begin 
	d1 := -d1;

	for p := 0 to m^.u do begin 

		pixel(m^.renderer, x, y);

		if (d1 <= m^.kt) then  begin 
			if (m^.oct2 = 0) then  begin 
				x:= x + 1;
			 end else begin 
				if (m^.quad4 = 0) then  begin 
					y:= y + 1;
				 end else begin 
					y:= y - 1;
				 end;
			 end;
			d1:= d1 + m^.kv;
		 end else begin 	
			x:= x + 1;
			if (m^.quad4 = 0) then  begin 
				y:= y + 1;
			 end else begin 
				y:= y - 1;
			 end;
			d1:= d1 + m^.kd;
		 end;
	 end;

	m^.tempx := x;
	m^.tempy := y;
 end;

(*!
brief Internal cFunction to to draw one iteration of the Murphy algorithm.

param m cPointer to  for murphy iterator.
param miter Iteration count.
param ml1bx X coordinate of a point.
param ml1by Y coordinate of a point.
param ml2bx X coordinate of a point.
param ml2by Y coordinate of a point.
param ml1x X coordinate of a point.
param ml1y Y coordinate of a point.
param ml2x X coordinate of a point.
param ml2y Y coordinate of a point.

*)
function _murphyIteration(m: PSDL2_gfxMurphyIterator; miter: byte; 
	ml1bx, ml1by, ml2bx, ml2by, ml1x, ml1y, ml2x, ml2y: integer): pointer;
var
	atemp1, atemp2, ftmp1, ftmp2, m1x, m1y, m2x, m2y, fix, fiy, lax, lay, curx, cury: integer;
	px,py : pinteger;
	b: PSDL2_gfxBresenhamIterator;
begin 

	if (miter > 1) then  begin 
		if (m^.first1x <> -32768) then  begin 
			fix := round((m^.first1x + m^.first2x) / 2);
			fiy := round((m^.first1y + m^.first2y) / 2);
			lax := round((m^.last1x + m^.last2x) / 2);
			lay := round((m^.last1y + m^.last2y) / 2);
			curx := round((ml1x + ml2x) / 2);
			cury := round((ml1y + ml2y) / 2);

			atemp1 := (fix - curx);
			atemp2 := (fiy - cury);
			ftmp1 := atemp1 * atemp1 + atemp2 * atemp2;
			atemp1 := (lax - curx);
			atemp2 := (lay - cury);
			ftmp2 := atemp1 * atemp1 + atemp2 * atemp2;

			if (ftmp1 <= ftmp2) then  begin 
				m1x := m^.first1x;
				m1y := m^.first1y;
				m2x := m^.first2x;
				m2y := m^.first2y;
			 end else begin 
				m1x := m^.last1x;
				m1y := m^.last1y;
				m2x := m^.last2x;
				m2y := m^.last2y;
			 end;

			atemp1 := (m2x - ml2x);
			atemp2 := (m2y - ml2y);
			ftmp1 := atemp1 * atemp1 + atemp2 * atemp2;
			atemp1 := (m2x - ml2bx);
			atemp2 := (m2y - ml2by);
			ftmp2 := atemp1 * atemp1 + atemp2 * atemp2;

			if (ftmp2 >= ftmp1) then  begin 
				ftmp1 := ml2bx;
				ftmp2 := ml2by;
				ml2bx := ml2x;
				ml2by := ml2y;
				ml2x := ftmp1;
				ml2y := ftmp2;
				ftmp1 := ml1bx;
				ftmp2 := ml1by;
				ml1bx := ml1x;
				ml1by := ml1y;
				ml1x := ftmp1;
				ml1y := ftmp2;
			 end;

			(*
			* Lock the surface 
			*)
			_bresenhamInitialize(@b, m2x, m2y, m1x, m1y);
			repeat 
				pixel(m^.renderer, b^.x, b^.y);
			until (_bresenhamIterate(@b) = 0);

			_bresenhamInitialize(@b, m1x, m1y, ml1bx, ml1by);
			repeat 
				pixel(m^.renderer, b^.x, b^.y);
			until (_bresenhamIterate(@b) = 0);

			_bresenhamInitialize(@b, ml1bx, ml1by, ml2bx, ml2by);
			repeat 
				pixel(m^.renderer, b^.x, b^.y);
			until (_bresenhamIterate(@b) = 0);

			_bresenhamInitialize(@b, ml2bx, ml2by, m2x, m2y);
			repeat 
				pixel(m^.renderer, b^.x, b^.y);
			until (_bresenhamIterate(@b) = 0);

			px[0] := m1x;
			px[1] := m2x;
			px[2] := ml1bx;
			px[3] := ml2bx;
			py[0] := m1y;
			py[1] := m2y;
			py[2] := ml1by;
			py[3] := ml2by;			
			polygon(m^.renderer, px, py, 4);						
		 end;
	 end;

	m^.last1x := ml1x;
	m^.last1y := ml1y;
	m^.last2x := ml2x;
	m^.last2y := ml2y;
	m^.first1x := ml1bx;
	m^.first1y := ml1by;
	m^.first2x := ml2bx;
	m^.first2y := ml2by;
 end;


// >> Following declaration is a macro definition!

function HYPOT(x,y: integer): double;
begin
 result:= sqrt(x*x + y*y);
end;

(*!
brief Internal cFunction to to draw wide lines with Murphy algorithm.

Draws lines parallel to ideal line.

param m cPointer to  for murphy iterator.
param x1 X coordinate of first point.
param y1 Y coordinate of first point.
param x2 X coordinate of second point.
param y2 Y coordinate of second point.
param width Width of line.
param miter Iteration count.

*)
function _murphyWideline(m: PSDL2_gfxMurphyIterator; x1, y1, x2, y2: integer; width, miter: byte): pointer;
var
	offset: single;
	tmp, temp: integer;
	ptx, pty, ptxx, ptxy, ml1x, ml1y, ml2x, ml2y, ml1bx, ml1by, ml2bx, ml2by: integer;
	d0, d1: integer;		(* difference terms d0=perpendicular to line, d1=along line *)
	q: integer;			(* pel counter,q=perpendicular to line *)
	dd: integer;			(* distance along line *)
	tk: integer;			(* thickness threshold *)
	ang: double;		(* angle for initial point calculation *)
	sang, cang: double;
begin 	
	offset := width / 2;


	(* Initialisation *)
	m^.u := x2 - x1;	(* delta x *)
	m^.v := y2 - y1;	(* delta y *)

	if (m^.u < 0) then begin 	(* swap to make sure we are in quadrants 1 or 4 *)
		temp := x1;
		x1 := x2;
		x2 := temp;
		temp := y1;
		y1 := y2;
		y2 := temp;		
		m^.u:= m^.u * -1;
		m^.v:= m^.v * -1;
	 end;

	if (m^.v < 0) then begin 	(* swap to 1st quadrant and flag *)
		m^.v:= m^.v * -1;
		m^.quad4 := 1;
	 end else begin 
		m^.quad4 := 0;
	 end;

	if (m^.v > m^.u) then begin 	(* swap things if in 2 octant *)
		tmp := m^.u;
		m^.u := m^.v;
		m^.v := tmp;
		m^.oct2 := 1;
	 end else begin 
		m^.oct2 := 0;
	 end;

	m^.ku := m^.u + m^.u;	(* change in l for square shift *)
	m^.kv := m^.v + m^.v;	(* change in d for square shift *)
	m^.kd := m^.kv - m^.ku;	(* change in d for diagonal shift *)
	m^.kt := m^.u - m^.kv;	(* diag/square decision threshold *)

	d0 := 0;
	d1 := 0;
	dd := 0;

	ang := arctan(m^.v / m^.u);	(* calc new initial point - offset both sides of ideal *)	
	sang := sin(ang);
	cang := cos(ang);

	if (m^.oct2 = 0) then  begin 
		ptx := x1 + round(offset * sang);
		if (m^.quad4 = 0) then  begin 
			pty := y1 - round(offset * cang);
		 end else begin 
			pty := y1 + round(offset * cang);
		 end;
	 end else begin 
		ptx := x1 - round(offset * cang);
		if (m^.quad4 = 0) then  begin 
			pty := y1 + round(offset * sang);
		 end else begin 
			pty := y1 - round(offset * sang);
		 end;
	 end;

	(* used here for constant thickness line *)
	tk := round(4 * HYPOT(ptx - x1, pty - y1) * HYPOT(m^.u, m^.v));

	if (miter = 0) then  begin 
		m^.first1x := -32768;
		m^.first1y := -32768;
		m^.first2x := -32768;
		m^.first2y := -32768;
		m^.last1x := -32768;
		m^.last1y := -32768;
		m^.last2x := -32768;
		m^.last2y := -32768;
	 end;
	ptxx := ptx;
	ptxy := pty;

	for q := 0 to tk do begin 	(* outer loop, stepping perpendicular to line *)

		_murphyParaline(m, ptx, pty, d1);	(* call to inner loop - right edge *)
		if (q = 0) then  begin 
			ml1x := ptx;
			ml1y := pty;
			ml1bx := m^.tempx;
			ml1by := m^.tempy;
		 end else begin 
			ml2x := ptx;
			ml2y := pty;
			ml2bx := m^.tempx;
			ml2by := m^.tempy;
		 end;
		if (d0 < m^.kt) then begin 	(* square move *)
			if (m^.oct2 = 0) then  begin 
				if (m^.quad4 = 0) then  begin 
					pty:= pty + 1;
				 end else begin 
					pty:= pty - 1;
				 end;
			 end else begin 
				ptx:= ptx + 1;
			 end;
		 end else begin 	(* diagonal move *)
			dd:= dd + m^.kv;
			d0:= d0 - m^.ku;
			if (d1 < m^.kt) then begin 	(* normal diagonal *)
				if (m^.oct2 = 0) then  begin 
					ptx:= ptx - 1;
					if (m^.quad4 = 0) then  begin 
						pty:= pty + 1;
					 end else begin 
						pty:= pty - 1;
					 end;
				 end else begin 
					ptx:= ptx + 1;
					if (m^.quad4 = 0) then  begin 
						pty:= pty - 1;
					 end else begin 
						pty:= pty + 1;
					 end;
				 end;
				d1:= d1 + m^.kv;
			 end else begin 	(* double square move, extra parallel line *)
				if (m^.oct2 = 0) then  begin 
					ptx:= ptx - 1;
				 end else begin 
					if (m^.quad4 = 0) then  begin 
						pty:= pty - 1;
					 end else begin 
						pty:= pty + 1;
					 end;
				 end;
				d1:= d1 + m^.kd;
				if (dd > tk) then  begin 
					_murphyIteration(m, miter, ml1bx, ml1by, ml2bx, ml2by, ml1x, ml1y, ml2x, ml2y);
					Exit;	(* breakout on the extra line *)
				 end;
				_murphyParaline(m, ptx, pty, d1);
				if (m^.oct2 = 0) then  begin 
					if (m^.quad4 = 0) then  begin 
						pty:= pty + 1;
					 end else begin 
						pty:= pty - 1;
					 end;
				 end else begin 
					ptx:= ptx + 1;
				 end;
			 end;
		 end;
		dd:= dd + m^.ku;
		d0:= d0 + m^.kv;
	 end;

	_murphyIteration(m, miter, ml1bx, ml1by, ml2bx, ml2by, ml1x, ml1y, ml2x, ml2y);
 end;


(*!
brief Draw a thick line with alpha blending.

param dst The surface to draw on.
param x1 X coordinate of the first point of the line.
param y1 Y coordinate of the first point of the line.
param x2 X coordinate of the second point of the line.
param y2 Y coordinate of the second point of the line.
param width Width of the line in pixels. Must be >0.
param color The color value of the line to draw ($RRGGBBAA). 

returns Returns 0 on success, -1 on failure.
*)
function thickLineColor(
	var renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	width: byte; 
	color: cardinal): Integer;
var
	c: pbyte;
begin 	
	c:= @color;
	result:= thickLineRGBA(renderer, x1, y1, x2, y2, width, c[0], c[1], c[2], c[3]);
 end;

(*!
brief Draw a thick line with alpha blending.

param dst The surface to draw on.
param x1 X coordinate of the first point of the line.
param y1 Y coordinate of the first point of the line.
param x2 X coordinate of the second point of the line.
param y2 Y coordinate of the second point of the line.
param width Width of the line in pixels. Must be >0.
param r The red value of the character to draw. 
param g The green value of the character to draw. 
param b The blue value of the character to draw. 
param a The alpha value of the character to draw.

returns Returns 0 on success, -1 on failure.
*)	
function thickLineRGBA(
	var renderer: SDL_Renderer; 
	x1: integer; 
	y1: integer; 
	x2: integer; 
	y2: integer; 
	width: byte; 
	r: byte; 
	g: byte; 
	b: byte; 
	a: byte): Integer;
var
	wh: Integer;
	m: SDL2_gfxMurphyIterator;
begin 

	if (renderer = 0) then  begin 
		result:= -1;
	 end;
	if (width < 1) then  begin 
		result:= -1;
	 end;

	(* Special case: thick "point" *)
	if ((x1 = x2) and (y1 = y2)) then  begin 
		wh := round(width / 2);
		result:= boxRGBA(renderer, x1 - wh, y1 - wh, x2 + width, y2 + width, r, g, b, a);		
	 end;

	(*
	* Set color
	*)
	result := 0;
	if (a=255) then
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_NONE)
	else
	 result:= result or SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
	result:= result or SDL_SetRenderDrawColor(renderer, r, g, b, a);

	(* 
	* Draw
	*)
	m.renderer := renderer;
	_murphyWideline(@m, x1, y1, x2, y2, width, 0);
	_murphyWideline(@m, x1, y1, x2, y2, width, 1);

	result:=(0);
 end;

initialization
 gfxPrimitivesPolyIntsGlobal := nil;
 gfxPrimitivesPolyAllocatedGlobal := 0;


end.
