-module(demo).
-import(even,[is_even/1]).
-import(io,[format/2]).
-export([double/1]).
-export([bump/1]).
-export([sum/1]).
-export([sum_for/2]).
-export([len/1]).
-export([average/1]).
-export([fizz_buzz/1]).
-export([reverse/1]).
-export([for/2]).
-export([thro/1]).
-export([print_even/2]).

%Hello world
%This is a comment

double(Value) -> times(Value, 2).
times(X,Y) -> X*Y.

bump([]) -> [];
bump([Head|Tail]) -> [Head+1|bump(Tail)].

sum([]) -> 0;
sum([Head|Tail]) -> Head+sum(Tail).

sum_for(Start,End) -> sum(for(Start,End)).

len([]) -> 0;
len([_ | Tail]) -> 1 + len(Tail).

average([]) -> 0.0;
average(List) -> sum(List) / len(List).

fizz_buzz([]) -> [];
fizz_buzz(Val) when (((Val rem 3) == 0) and ((Val rem 5) == 0)) -> fizzBuzz;
fizz_buzz(Val) when Val rem 3 == 0 -> fizz;
fizz_buzz(Val) when Val rem 5 == 0 -> buzz;
fizz_buzz([Head|Tail]) -> [fizz_buzz(Head)|fizz_buzz(Tail)];
fizz_buzz(Val) -> Val.

reverse([]) -> [];
reverse([Head|Tail]) -> reverse(Tail)++[Head].

%reverse(List) -> reverse_acc(List, []).
%reverse_acc([], Acc) -> Acc;
%reverse_acc([H | T], Acc) -> reverse_acc(T, [H | Acc]).

%For loops ***********************************************************************
%Make me a list of numbers from 1 to 100

for(Start,End) when Start < End -> forReal(Start,End,[]);
for(Start,End) when Start > End -> forRealBack(Start,End,[]);
for(Start,End) when Start == End -> [Start].


forReal(Index, Max, List) when Index =< Max -> forReal(Index+1,Max,List++[Index]);
forReal(_I,_M,List) -> List.

forRealBack(Index, Max, List) when Index >= Max -> forRealBack(Index-1,Max,List++[Index]);
forRealBack(_I,_M,List) -> List.

%For loops ***********************************************************************

thro(Val) ->
   try(i_Will_Throw(Val)) of
      Val -> {normal, Val}
   catch
      throw:Error -> {throw,Error}
   end.

i_Will_Throw(Val) when Val == 1 -> throw(its_a_one);
i_Will_Throw(Val) when Val == 2 -> throw(its_a_two);
i_Will_Throw(Val) -> Val.

print_even(Start,End) -> io:format("Numbers: ~p~n", [even:is_even(for(Start,End))]  ).




