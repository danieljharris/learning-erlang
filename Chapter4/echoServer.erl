-module(echoServer).
-export([go/0, pinger/0]).
-export([start/0, print/1, stop/0, server_fun/0]).

%%Exercise 3-1: An Echo Server


go() -> register(echo, spawn(echoServer, pinger, [])).

pinger() ->
	receive
		{ping, From} ->
			From ! {pong, self()},
			pinger();
		stop ->
			true
	end.



start() -> register(msg_server, spawn(echoServer, server_fun, [])).
print(Message) -> msg_server!{message, Message}.
stop() -> msg_server!stop.

server_fun() ->
	receive
		stop ->
			true;
		{message, Message} ->
			io:format("Here: ~p~n", [Message]),
			server_fun()
	end.
