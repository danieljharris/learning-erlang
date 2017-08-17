-module(link_ping_pong).
-export([start/0, print/1, stop/0]).
-export([init/0]).

% Exercise 6-1: The Linked Ping Pong Server

start() -> register(msg_server, spawn(link_ping_pong, init, [])).

print(Message) ->
	process_flag(trap_exit, true),
	link(whereis(msg_server)),
	msg_server!{message, Message, self()},
	receive
		{'EXIT', _Pid, Reason} -> {error, Reason};
		{reply, Reply} -> Reply
	end.

% Link method
stop() ->
	process_flag(trap_exit, true),
	link(whereis(msg_server)),
	msg_server!{stop, self()},
	receive
		{'EXIT', _Pid, Reason} -> {error, Reason};
		{reply, Reply} ->
			unlink(whereis(msg_server)),
			Reply
	end.

% Monitor method
% stop() ->
% 	msg_server!{stop, self()},
% 	% process_flag(trap_exit, true),
% 	Reference = erlang:monitor(process, whereis(cell)),
% 	receive
% 		{'DOWN',Reference,process, _Pid, Reason} -> Reason;
% 		{reply, Reply} ->
% 			erlang:demonitor(Reference),
% 			Reply
% 	end.



reply(Pid, Reply) -> Pid ! {reply, Reply}.


init() ->
	process_flag(trap_exit, true),
	loop().

loop() ->
	receive
		{'EXIT', _Pid, Reason} -> {error, Reason};
		{message, Message, From} ->
			reply(From, ["The message I receved: "|[Message]]),
			loop();
		{stop, _From} ->
			exit(self(), kill)
			% reply(_From, "Stopping...")
	end.
