-module(macros).
-export([dan/0, add/2, test/0, test1/0, showPerson/1, birthday/1]).
-record(person, {name, age, phone}).
-define(NAME, daniel).
-define(ADD(A, B), A + B).
-define(VALUE(Call),io:format("~p = ~p~n",[??Call,Call])).

% -define(DBG(Str, Args), ok).
% -define(DBG(Str, Args), io:format(Str, Args)).

-ifdef(debug).
	-define(DBG(Str, Args), io:format(Str, Args)).
-else.
	-define(DBG(Str, Args), ok).
-endif.


test1() -> ?VALUE(length([1,2,3])).

dan() -> ?NAME.

add(A, B) -> ?ADD(A, B).

test() ->
	Dan = #person{name="Dan",age=20,phone=01495},
	Name = Dan#person.name,
	Name.

showPerson(#person{age=Age,phone=Phone,name=Name}) ->
	io:format("name: ~p age: ~p phone: ~p~n", [Name,Age,Phone]).


birthday(#person{age=Age} = P) ->
	?DBG("in records1:birthday(~p)~n", [P]),
	P#person{age=Age+1}.