-module(extend_records).
-export([dan/0, test/0, showPerson/1, foobar/1]).

% Exercise 7-1: Extending Records
-record(address, {number, street, town, postcode}).
-record(person, {name, age, phone, address}).


dan() -> #person{name="Dan",age=20,phone=01495, address=#address{number = 123, street = "Wood Road"}}.

test() ->
	Dan = #person{name="Dan",age=20},
	Name = Dan#person.name,
	Name.

showPerson(#person{age=Age,phone=Phone,name=Name,address=Address}) ->
	io:format("Details:~n\tname: ~p~n\tage: ~p~n\tphone: ~p~n", [Name,Age,Phone]),
	showAddress(Address).


% Exercise 7-1: Extending Records
showAddress(#address{number=Number, street=Street, town=Town, postcode=Postcode}) ->
	io:format("Address:~n\tnumber: ~p~n\tstreet: ~p~n\ttown: ~p~n\tpostcode: ~p~n", [Number,Street,Town,Postcode]).


% Exercise 7-2: Record Guards
foobar(P) when is_record(P, person) -> P#person.name == "Joe";
foobar(_) -> false.
