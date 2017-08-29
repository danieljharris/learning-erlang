-module(list_comp).
-export([list3/0, sq/1, intersect/2, symdif/2]).

-vsn(1.0).

% Exercise 9-2: List Comprehensions

list3() ->
	[ X || X <- lists:seq(1, 10), X rem 3 == 0 ].

sq(List) ->
	[ X*X || X <- List, is_integer(X) ].

intersect(A,B) ->
	[ X || X <- A, Y <- B, X == Y ].

symdif(A,B) ->
	Diff = intersect(A,B),
	(A -- Diff) ++ (B -- Diff).