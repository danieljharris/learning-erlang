-module(list_len).
-export([split/0, pattern/0]).

-vsn(1.0).

% Exercise 9-5: Length Specifications in List Comprehensions

% Can split it up in to smaller sections
split() ->
	<< X:4, Y:2 >> = << 42:6 >>,
	{X,Y}.

% Doesent work because 4+4 does not equal 6 and 4+2 does not equal 8, lengths need to match
pattern() ->
	<<C:4,D:4>> = << 1998:6 >>,
	<<C:4,D:2>> = << 1998:8 >>.