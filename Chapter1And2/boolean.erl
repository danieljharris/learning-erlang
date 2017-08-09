-module(boolean).
-export([b_not/1]).
-export([b_and/2]).
-export([b_xor/2]).

%Hello world
%

b_not(Val) ->
  case Val of
    false -> true;
    true  -> false
  end.

b_and(One,Two) -> One == Two.

b_xor(One,Two) ->
   if
      One == Two -> false;
      One /= Two -> true
   end.
