-module(super_process).
-export([start_link/2, stop/1, add_child/2, stop_child/2]).
-export([init/1]).

% Interface
start_link(Name, ChildSpecList) ->
	register(Name, spawn_link(super_process, init, [ChildSpecList])), ok.

stop(Name) ->
	Name ! {stop, self()},
	receive {reply, Reply} -> Reply end.


% Exercise 6-3: A Supervisor Process (start_child & stop_child)
add_child(Name, Process) ->
	Name ! {add, self(), Process},
	receive {reply, Reply} -> Reply end.

stop_child(Name, Pid) ->
	Name ! {remove, self(), Pid},
	receive {reply, Reply} -> Reply end.
% Interface


init(ChildSpecList) ->
	process_flag(trap_exit, true),
	loop(start_children(ChildSpecList)).

start_children([]) -> [];
start_children([{M,F,A,T} | ChildSpecList]) ->
	case ( catch apply(M,F,A) ) of
		{ok, Pid} ->
			[ {Pid, {M,F,A,T,{0,0}}} | start_children(ChildSpecList) ];
		_ ->
			start_children(ChildSpecList)
	end.


% Don't know how to make the module not available to test 6-3 part two (spawn a child whose module is not available?)

restart_child(Pid, ChildList) ->
	{value, {Pid, {M,F,A,T,R}}} = lists:keysearch(Pid, 1, ChildList),

	{Min, Ammount} = R,
	{_,{_,CurrentMin,_}} = calendar:now_to_local_time(erlang:timestamp()),

	if
		Ammount == 5 ->
			% {error, restart_threshold_reached}
			io:format("Error threshold reached~n", []),
			[ lists:keydelete(Pid,1,ChildList) ];
		Min == CurrentMin -> 
			{ok, NewPid} = apply(M,F,A),
			[ {NewPid, {M,F,A,T,{Min, Ammount + 1}}} | lists:keydelete(Pid,1,ChildList) ];
		Min /= CurrentMin ->
			{ok, NewPid} = apply(M,F,A),
			[ {NewPid, {M,F,A,T,{CurrentMin, 0}}} | lists:keydelete(Pid,1,ChildList) ]
	end.


restart_child(Pid, ChildList, normal) ->
	{value, {Pid, {M,F,A,T,R}}} = lists:keysearch(Pid, 1, ChildList),
	case T of
		permanent -> 
			{ok, NewPid} = apply(M,F,A),
			[ {NewPid, {M,F,A,T,R}} | lists:keydelete(Pid,1,ChildList) ];
		transient ->
			[ lists:keydelete(Pid,1,ChildList) ]
	end.


add_new_child({M,F,A,T}, ChildList) ->
	case ( catch apply(M,F,A) ) of
		{ok, Pid} ->
			{Pid, [ {Pid, {M,F,A,T,{0,0}}} | ChildList ]}
	end.


loop(ChildList) ->
	receive
		{'EXIT', Pid, removed} ->
			loop([ lists:keydelete(Pid,1,ChildList) ]);
		{'EXIT', Pid, normal} ->
			NewChildList = restart_child(Pid, ChildList, normal),
			loop(NewChildList);
		{'EXIT', Pid, _Reason} ->
			NewChildList = restart_child(Pid, ChildList),
			loop(NewChildList);
		{add, From, NewChild} ->
			{Pid, NewChildList} = add_new_child(NewChild, ChildList),
			From ! {reply, Pid},
			loop(NewChildList);
		{remove, From, Pid} ->
			exit(Pid, removed),
			From ! {reply, ok},
			loop([ lists:keydelete(Pid,1,ChildList) ]);
		{stop, From} ->
			From ! {reply, terminate(ChildList)}
	end.

terminate([{Pid, _} | ChildList]) ->
	exit(Pid, kill),
	terminate(ChildList);
terminate(_ChildList) -> ok.



