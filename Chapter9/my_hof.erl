-module(my_hof).
-export([all/2, any/2, dropwhile/2, filter/2, foldl/3, map/2, partition/2]).

-vsn(1.0).

% Exercise 9-4: Existing Higher-Order Functions


all(_F, []) -> true;
all(F, [Head | Tail]) ->
	case F(Head) of
		true -> all(F, Tail);
		false -> false
	end.


any(_F, []) -> false;
any(F, [Head | Tail]) ->
	case F(Head) of
		true -> true;
		false -> any(F, Tail)
	end.


dropwhile(_F, []) -> [];
dropwhile(F, [Head|Tail] = List) ->
	case F(Head) of
		true -> dropwhile(F, Tail);
		false -> List
	end.
	
filter(_P,[]) -> [];
filter(P,[X|Xs]) ->
	case P(X) of
		true ->
			[X| filter(P,Xs)];
		_ ->
			filter(P,Xs)
	end.

foldl(_F, Acc, []) -> Acc;
foldl(F, Acc, [X|Xs]) ->
	NewAcc = F(X, Acc),
	foldl(F, NewAcc, Xs).

map(_F,[]) -> [];
map(F,[X|Xs]) -> [F(X) | map(F,Xs)].


partition(F, List) -> partition(F, [], [], List).

partition(_F, TList, FList, []) -> [TList, FList];
partition(F, TList, FList, [Head|Tail])->
	case F(Head) of
		true -> partition(F, [Head | TList], FList, Tail);
		false -> partition(F, TList, [Head | FList], Tail)
	end.























