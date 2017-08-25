-module(shapes).
-export([perimeter/1, area/1]).

-record(circle, {radius}).
-record(rectangle, {length, width}).
-record(triangle, {side1, side2, side3}).

% Exercise 7-4: Records and Shapes

perimeter( #circle{radius=Radius} ) ->
  2 * math:pi() * Radius;

perimeter( #rectangle{length=Length, width=Width} )  ->
  (2 * Length) + (2 * Width);

perimeter( #triangle{side1=Side1, side2=Side2, side3=Side3} ) ->
  Side1 + Side2 + Side3.



area( #circle{radius=Radius} ) ->
  math:pow(math:pi() * Radius, 2);

area( #rectangle{length=Length, width=Width} ) ->
  Length * Width;

area( #triangle{side1=Side1, side2=Side2, side3=Side3} ) ->
  P = ( (Side1 + Side2 + Side3)/2 ),
  math:sqrt( P*(P-Side1)*(P-Side2)*(P-Side3) ).
