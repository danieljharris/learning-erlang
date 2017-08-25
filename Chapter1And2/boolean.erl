-module(boolean).
-export([b_not/1]).
-export([b_and/2]).
-export([b_xor/2]).

%Hello world
%

% b_not(Val) ->
%   case Val of
%     false -> true;
%     true  -> false
%   end.

b_not(true)  -> false;
b_not(false) -> true.



% b_and(One,One) -> One == Two.

b_and(true, true) -> true;
b_and(_,_) 	      -> false.



% b_xor(One,Two) ->
%    if
%       One == Two -> false;
%       One /= Two -> true
%    end.

b_xor(One, One) -> false;
b_xor(_, _)     -> true.