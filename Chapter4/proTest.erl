-module(proTest).
-export([go/0, loop/0]).

go() ->
	Pid = spawn(proTest, loop, []),
	Pid ! {ping, self()},
	io:format("ping ~w~n",[self()]),
	receive
		{pong, From} ->
			io:format("pong ~w~n",[From])
	end,
	Pid ! stop.

loop() ->
	receive
		{ping, From} ->
			From ! {pong, self()},
			loop();
		stop ->
			true
	end.


go1() ->
	register(echo, spawn(proTest, loop1, [])),
	echo ! {ping, self()},
	io:format("ping ~w~n",[self()]),
	receive
		{pong, From} ->
			io:format("pong ~w~n",[From])
	end.

loop1() ->
	receive
		{ping, From} ->
			From ! {pong, self()},
			loop1();
		stop ->
			true
	end.



send_after(Time, Msg) ->
	spawn(proTest, send, [self(),Time,Msg]),
	receive
		{message, Message} ->
			io:format("Here: ~p~n", [Message]);
		stop ->
			true
	end.

send(Pid, Time, Msg) ->
	receive
	after Time -> Pid ! Msg
	end.

sleep(T) ->
	receive
	after T -> true
	end.




start(Num) -> start_proc(Num, self()).

start_proc(0, Pid) -> Pid ! ok;
start_proc(Num, Pid) ->
	NPid = spawn(proTest, start_proc, [Num-1, Pid]),
	NPid ! ok,
	receive
		ok -> ok
	end.








% proReceive() ->
% 	receive
% 		{message, Message} -> Message;
% 		{pid, Pid}         -> Pid ! "Pong!";
% 		{error, Error} 	   -> {error, Error};
% 		_Other			   -> {error, unexpected_message_receved}
% 	end.

