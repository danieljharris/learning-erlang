-module(add_two).
-export([start/0, stop/0, request/1, loop/0]).

start() ->
	process_flag(trap_exit, true),
	Pid = spawn_link(add_two, loop, []),
	register(add_two, Pid),
	{ok, Pid}.

stop() ->
	add_two ! stop.

request(Int) ->
	add_two ! {request, self(), Int},
	receive
		{result, Result}       -> Result;
		{'EXIT', _Pid, Reason} -> {error, Reason}
	after 1000 -> timeout
	end.

loop() ->
	receive
		{request, Pid, Msg} ->
			Pid ! {result, Msg + 2},
			loop();
		stop -> true
	end.