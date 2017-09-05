-module(echoServer).
-export([start/0, print/1, stop/0]).
-export([server_fun/0]).

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
