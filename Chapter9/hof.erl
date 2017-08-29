-module(hof).
-export([print/2, print_even/2, smaller_or_equal/2, concat/1, sum/1]).

-vsn(1.0).

% Exercise 9-1: Higher-Order Functions

foreach(_,[]) -> ok;
foreach(F,[X|Xs]) ->
    F(X),
    foreach(F,Xs).

print(Val) ->
  io:format("Integers: ~p~n", [Val]).

print(Start, End) ->
  foreach(fun print/1, lists:seq(Start, End)).

print_even(Start, End) ->
  Even = lists:filter(fun(A) -> A rem 2 == 0 end, lists:seq(Start, End) ),
  foreach(fun print/1, Even).


smaller_or_equal(List, Max) ->
  lists:filter(fun(A) -> A =< Max end, List).


% Needed to use ++ because I couldent merge two lists without it, couldent use [ | ]
concat(List) ->
  lists:foldl(fun(Segment, Acc) -> Acc ++ Segment end, [], List).


sum(List) ->
  lists:foldl(fun(Num,Acc) -> Num + Acc end, 0, List).
