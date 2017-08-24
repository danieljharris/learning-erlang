-module(reliable_mutex).
-export([start/0, stop/0]).
-export([wait/0, signal/0]).
-export([init/0]).

% Exercise 6-2: A Reliable Mutex Semaphore


%% Link method
% msg(Message) ->
% 	process_flag(trap_exit, true),
% 	(catch link(whereis(cell))),
% 	cell ! {Message, self()},
% 	receive
% 		{'EXIT', _Pid, Reason} ->
% 			stop(),
% 			{error, Reason};
% 		{reply, Reply} ->
% 			unlink(whereis(cell)),
% 			Reply
% 	end.

%% Monitor method
% msg(Message) ->
% 	process_flag(trap_exit, true),
% 	Reference = erlang:monitor(process, whereis(cell)),
% 	cell ! {Message, self()},
% 	receive
% 		{'DOWN',Reference,process, _Pid, Reason} ->
% 			stop(),
% 			Reason;
% 		{reply, Reply} ->
% 			erlang:demonitor(Reference),
% 			Reply
% 	end.



start() ->
	register(mutex, spawn(reliable_mutex, init, [])).

stop() ->
	mutex ! stop.

wait() ->
	mutex ! {wait, self()},
	receive ok -> ok end.

signal() ->
	mutex ! {signal, self()}, ok.



init() ->
	process_flag(trap_exit, true),
	free().


% States: free, busy, terminate
free() ->
	receive
		{wait, Pid} ->
			case process_info(Pid) of
				undefined ->
					free();
				_ ->
					Pid ! ok,
					busy(Pid)
			end;
		stop ->
			terminate()
	end.


%% Link method
busy(Pid) ->

	try link(Pid) of
		true -> ok
	catch
		_:_ -> {error, could_not_link}
	end,


	receive
		{signal, Pid} ->
			try unlink(Pid) of
				true -> ok
			catch
				_:_ -> {error, could_not_un_link}
			end,
			free();


		{'EXIT', _Pid, _Reason} ->
			try unlink(Pid) of
				true -> ok
			catch
				_:_ -> {error, could_not_un_link}
			end,
			terminate()
	end.

%% Monitor method
% busy(Pid) ->
% 	Reference = erlang:monitor(process, whereis(cell)),
% 	receive
% 		{signal, Pid} ->
% 			erlang:demonitor(Reference),
% 			free();

% 		{'DOWN', _Reference, process, _Pid, _Reason} ->
% 			erlang:demonitor(Reference),
% 			terminate()
% 	end.



terminate() ->
	receive
		{wait, Pid} ->
			exit(Pid, kill),
			terminate()
	after 0 -> ok
	end.




