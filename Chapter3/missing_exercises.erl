-module(missing_exercises).

%Exercise 3-1: Evaluating Expressions
%Exercise 3-2: Creating Lists (Create)
-export([sum_for/2]).
-export([for/2]).
-export([reverse_for/2]).

%Exercise 3-7: Using Library Modules
-export([new/0, destroy/1, write/3, delete/2, read/2, match/2]).


sum([]) -> 0;
sum([Head|Tail]) -> Head+sum(Tail).

%%Exercise 3-1: Evaluating Expressions
sum_for(Start,End) -> sum(for(Start,End)).


%%Exercise 3-2: Creating Lists (Create)
for(Start,End) when Start < End -> forReal(Start,End,[]);
for(Start,End) when Start > End -> forRealBack(Start,End,[]);
for(Start,End) when Start == End -> [Start].

forReal(Index, Max, List) when Index =< Max -> forReal(Index+1,Max,List++[Index]);
forReal(_I,_M,List) -> List.

forRealBack(Index, Max, List) when Index >= Max -> forRealBack(Index-1,Max,List++[Index]);
forRealBack(_I,_M,List) -> List.

reverse([]) -> [];
reverse([Head|Tail]) -> reverse(Tail)++[Head].

%%Exercise 3-2: Creating Lists (Reverse)
reverse_for(Start, End) -> reverse( for(Start, End) ).


%%Exercise 3-7: Using Library Modules
new() 					-> [].
destroy(_) 				-> 0.
write(Key, Element, Db) -> lists:append([{Key, Element}], Db).
delete(Key, Db) 		-> lists:delete( read(Key, Db), Db ).
read(Key, Db) 			-> lists:keyfind(Key, 1, Db).
match(Element, Db) 		-> lists:keyfind(Element, 2, Db).