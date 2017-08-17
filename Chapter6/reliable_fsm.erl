-module(reliable_fsm).
-export([start/0, stop/0, un_hook/0, hook/0, other_un_hook/0, other_hook/0, call/1, get_call/1]).
-export([idle/0, dial/0, wait_answer/1, ringing/1, connected/1]).

start() -> register(cell, spawn(reliable_fsm, idle, [])).
stop() 	-> cell ! stop.

un_hook() 			-> msg(off_hook).
hook() 				-> msg(on_hook).
other_un_hook() 	-> msg(other_off_hook).
other_hook() 		-> msg(other_on_hook).
call(Number) 		-> msg({Number, calling}).
get_call(Number) 	-> msg({Number, incoming}).


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
msg(Message) ->
	process_flag(trap_exit, true),
	Reference = erlang:monitor(process, whereis(cell)),
	cell ! {Message, self()},
	receive
		{'DOWN',Reference,process, _Pid, Reason} ->
			stop(),
			Reason;
		{reply, Reply} ->
			erlang:demonitor(Reference),
			Reply
	end.




reply(To, Msg) ->
	To ! {reply, Msg}.

%States
idle() ->
	receive
		{{Number, incoming}, Pid} ->
			reply(Pid, receveing_call),
			%start_ringing(),
			ringing(Number);
		{off_hook, Pid} ->
			reply(Pid, picking_up_phone),
			%start_tone(),
			dial();
		stop ->
			true;
		{_Other, Pid} ->
			reply(Pid, wrong_action_for_state),
			idle()
	end.

dial() ->
	receive
		{{Number, calling}, Pid} ->
			reply(Pid, calling_number),
			%stop_tone(),
			%start_ringing(),
			wait_answer(Number);
		{on_hook, Pid} ->
			reply(Pid, hooking_phone),
			%stop_tone(),
			idle();
		{_Other, Pid} ->
			reply(Pid, wrong_action_for_state),
			dial()
	end.

wait_answer(Number) ->
	receive
		{other_off_hook, Pid} ->
			reply(Pid, other_answered),
			%stop_ringing(),
			connected(Number);
		{on_hook, Pid} ->
			reply(Pid, hooking_phone),
			%stop_ringing(),
			idle();
		{_Other, Pid} ->
			reply(Pid, wrong_action_for_state),
			wait_answer(Number)
	end.

ringing(Number) ->
	receive
		{other_on_hook, Pid} ->
			reply(Pid, call_dropped_by_other),
			%stop_ringing(),
			idle();
		{off_hook, Pid} ->
			reply(Pid, answer_call),
			%stop_ringing(),
			connected(Number);
		{_Other, Pid} ->
			reply(Pid, wrong_action_for_state),
			ringing(Number)
	end.

connected(Number) ->
	receive
		{on_hook, Pid}->
			reply(Pid, call_dropped),
			idle();
		{other_on_hook, Pid} ->
			reply(Pid, call_dropped),
			idle();
		{_Other, Pid} ->
			reply(Pid, wrong_action_for_state),
			connected(Number)
	end.
%States -
