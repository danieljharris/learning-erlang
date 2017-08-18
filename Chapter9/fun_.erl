-module(fun_).
-export([map/2, filter/2, foreach/2, times/1, double/1, sendTo/1]).

-vsn(1.0).


% fun_:map(fun(Val) -> Val * 2 end,[1,2,3,4,5,6,7,8,9]).
% fun_:map(fun(Val) -> Val + 10 end,[1,2,3,4,5,6,7,8,9]).
map(F,[]) -> [];
map(F,[X|Xs]) -> [F(X) | map(F,Xs)].


% fun_:filter(fun(Val) -> Val rem 2 == 0 end,[1,2,3,4,5,6,7,8,9]).
% fun_:filter(fun(Val) -> Val rem 5 == 0 end,[1,2,3,4,5,6,7,8,9]).
filter(P,[]) -> [];
filter(P,[X|Xs]) ->
	case P(X) of
		true ->
			[X| filter(P,Xs)];
		_ ->
			filter(P,Xs)
	end.


% fun_:foreach(fun(Val) -> io:format("Element: ~p~n", [Val]) end,[1,2,3,4,5,6,7,8,9]).
% fun_:foreach(
% 	fun(Val) -> 
% 		if
% 			Val rem 2 == 0	-> io:format("Fiz, ", []);
% 			Val rem 5 == 0	-> io:format("Buz, ", []);
% 			true			-> io:format("~p, ", [Val])
% 		end
% 	end,
% 	[1,2,3,4,5,6,7,8,9]).

foreach(F,[]) -> ok;
foreach(F,[X|Xs]) ->
	F(X),
	foreach(F,Xs).


% Double = fun_:times(2), Double(10).
% Triple = fun_:times(3), Triple(10).
times(X) ->
	fun (Y) -> X * Y end.


% fun_:double([1,2,3]).
double(List) ->
	map(times(2),List).



% fun_:sendTo(self()).
sendTo(Pid) ->
	fun (X) -> Pid ! {message, X}
	end.











