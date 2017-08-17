-module(fsm).
-export([start/0, stop/0, un_hook/0, hook/0, other_un_hook/0, other_hook/0, call/1, get_call/1]).
-export([idle/0, dial/0, wait_answer/1, ringing/1, connected/1]).


start() ->
	event_manager:start(fsm, [{log_handler, "PhoneLog"}]),
	register(cell, spawn(fsm, idle, [])).
stop() 	->
	event_manager:stop(fsm),
	cell ! stop.

un_hook()			-> msg(off_hook).
hook()				-> msg(on_hook).
other_un_hook()		-> msg(other_off_hook).
other_hook()		-> msg(other_on_hook).
call(Number)		-> msg({Number, calling}).
get_call(Number)	-> msg({Number, incoming}).

msg(Message) ->
	cell ! {Message, self()},
	receive
		{reply, Reply} -> Reply
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
			true
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
			idle()
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
			idle()
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
			connected(Number)
	end.

connected(Number) ->
	event_manager:send_event(fsm, {start_call, Number, phone_call}),
	receive
		{on_hook, Pid} ->
			event_manager:send_event(fsm, {end_call, Number, phone_call}),
			reply(Pid, call_dropped),
			idle();
		{other_on_hook, Pid} ->
			event_manager:send_event(fsm, {end_call, Number, phone_call}),
			reply(Pid, call_dropped),
			idle()
	end.
%States -
