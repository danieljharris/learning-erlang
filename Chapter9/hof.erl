-module(hof).
-export([print/2, print_even/2, smaller_or_equal/2, concat/0, sum/1]).

-vsn(1.0).

% Exercise 9-1: Higher-Order Functions

foreach(F,[]) -> ok;
foreach(F,[X|Xs]) ->
		F(X),
		foreach(F,Xs).

% filter(P,[]) -> [];
% filter(P,[X|Xs]) ->
% 	case P(X) of
% 		true ->
% 			[X| filter(P,Xs)];
% 		_ ->
% 			filter(P,Xs)
% 	end.


print_fun() ->
	fun(Val) -> io:format("Integers: ~p~n", [Val]) end.

print(Start, End) ->
	foreach(print_fun(), lists:seq(Start, End)).

print_even(Start, End) ->
	Even = lists:filter(fun(A) -> A rem 2 == 0 end, lists:seq(Start, End) ),
	foreach(print_fun(), Even).


smaller_or_equal(List, Max) ->
	lists:filter(fun(A) -> A =< Max end, List).


% Not sure if this is how they wanted me to structure the function
% but its the best way I could get working that involved funs
concat() -> fun(List) -> lists:concat(List) end.

% do_concat() ->
% 	fun(F, List) ->
% 		if
% 			List  == [] -> [];
% 			true ->
% 				[Head|Tail] = List,
% 				[ Head | F(F, Tail)] 
% 		end
% 	end.



sum(List) ->
	lists:foldl(fun(Num,Acc) -> Num + Acc end, 0, List).



