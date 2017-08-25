-module(record).
-export([dan/0, test/0, showPerson/1]).
-record(person, {name, age, phone}).

dan() -> #person{name="Dan",age=20,phone=01495}.

test() ->
	Dan = #person{name="Dan",age=20,phone=01495},
	Name = Dan#person.name,
	Name.

showPerson(#person{age=Age,phone=Phone,name=Name}) ->
	io:format("name: ~p age: ~p phone: ~p~n", [Name,Age,Phone]).

