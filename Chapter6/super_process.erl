-module(super_process).
-export([start_link/2, stop/1, add_child/2, stop_child/2]).
-export([init/0]).

% Interface
start_link(Name, ChildSpecList) ->
	register(Name, spawn_link(super_process, init, [])),
	start_children(Name, ChildSpecList).

stop(Name) ->
	Name ! {stop, self()},
	receive {reply, Reply} -> Reply end.


% Exercise 6-3: A Supervisor Process (start_child & stop_child)
% add_child(Name, {Module, Function, Arguments, Type})
add_child(Name, Process) ->
	Name ! {add, self(), Process},
	receive {reply, Reply} -> Reply end.

stop_child(Name, Id) ->
	Name ! {remove, self(), Id},
	receive {reply, Reply} -> Reply end.
% Interface



init() ->
	process_flag(trap_exit, true),
	loop([]).

start_children(_, []) -> [];
start_children(Name, [ {Module, Function, _, _} = NewProcess | ChildSpecList]) ->
	Id = add_child(Name, NewProcess),
	[{Module,Function,Id} | start_children(Name, ChildSpecList)].


% Don't know how to make the module not available to test 6-3 part two (spawn a child whose module is not available?)

restart_child(_, []) -> {error, no_registered_children};
restart_child(_, [[]]) -> {error, no_registered_children};
restart_child(Pid, ChildList) ->
	{value, {Id, Pid, {M,F,A,T,R}}} = lists:keysearch(Pid, 2, ChildList),

	{Time, Ammount} = R,
	{Date, {Hour,Minute,_}} = calendar:now_to_local_time(erlang:timestamp()),
	TimeNoSec = {Date, {Hour,Minute}},

	if
		Ammount == 5 ->
			% {error, restart_threshold_reached}
			io:format("Error threshold reached~n", []),
			exit(Pid, removed),
			[ lists:keydelete(Pid,2,ChildList) ];
		Time == TimeNoSec -> 
			{ok, NewPid} = apply(M,F,A),
			[ {Id, NewPid, {M,F,A,T,{TimeNoSec, Ammount + 1}}} | lists:keydelete(Pid,2,ChildList) ];
		Time /= TimeNoSec ->
			{ok, NewPid} = apply(M,F,A),
			[ {Id, NewPid, {M,F,A,T,{TimeNoSec, 0}}} | lists:keydelete(Pid,2,ChildList) ]
	end.

restart_child(_, [], _) -> {error, no_registered_children};
restart_child(Pid, ChildList, normal) ->
	{value, {Id, Pid, {M,F,A,T,R}}} = lists:keysearch(Pid, 2, ChildList),
	case T of
		permanent -> 
			{ok, NewPid} = apply(M,F,A),
			[ {Id, NewPid, {M,F,A,T,R}} | lists:keydelete(Pid,2,ChildList) ];
		transient ->
			[ lists:keydelete(Pid,2,ChildList) ]
	end.


add_new_child({M,F,A,T}, ChildList) ->
	case ( catch apply(M,F,A) ) of
		{ok, Pid} ->
			{pid_to_list(Pid), [ {pid_to_list(Pid), Pid, {M,F,A,T,{0,0}}} | ChildList ]};
		_Other -> {error, failed_to_start_child}
	end.

id_to_pid(Id, ChildList) ->
	{value, {Id, Pid, _}} = lists:keysearch(Id, 1, ChildList),
	Pid.


loop(ChildList) ->
	receive
		{'EXIT', Pid, removed} ->
			loop(lists:keydelete(Pid,2,ChildList));
		{'EXIT', Pid, normal} ->
			case restart_child(Pid, ChildList, normal) of
				{error, _Reason} -> loop(ChildList);
				NewChildList -> loop(NewChildList)
			end;
		{'EXIT', Pid, _Reason} ->
			case restart_child(Pid, ChildList) of
				{error, _Reason} -> loop(ChildList);
				NewChildList -> loop(NewChildList)
			end;
		{add, From, NewChild} ->
			case add_new_child(NewChild, ChildList) of
				{error, Reason} ->
					From ! {reply, {error, Reason}},
					loop(ChildList);
				{Id, NewChildList} ->
					From ! {reply, Id},
					loop(NewChildList)
			end;
		{remove, From, Id} ->
			Pid = id_to_pid(Id, ChildList),
			exit(Pid, removed),
			From ! {reply, ok},
			loop( ChildList );
		{stop, From} ->
			From ! {reply, terminate(ChildList)}
	end.

terminate([{Pid, _} | ChildList]) ->
	exit(Pid, removed),
	terminate(ChildList);
terminate(_ChildList) -> ok.
