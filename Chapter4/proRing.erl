-module(proRing).
% -export([ring_start/2]).
% -export([ring_loop/4]).
-export([start/1, stop/0, message/2]).
-export([ring_loop/1]).

%%Exercise 4-2: The Process Ring
%Not sure what was meant by 'number of messages'
% ring(F_Pid, Length) ->
% 	if
% 		Length == 1 -> Pid = F_Pid;
% 		F_Pid  == 0 -> Pid = spawn(proRing, ring, [self(), Length -1]);
% 		F_Pid  /= 0 -> Pid = spawn(proRing, ring, [F_Pid, Length -1])
% 	end,
% 	receive
% 		stop ->
% 			true;
% 		loop ->
% 			io:format("I'm: ~p, I point at: ~p~n", [pid_to_list(self()), pid_to_list(Pid)]),
% 			Pid!loop
% 	end.


%%Exercise 4-2: The Process Ring (Updated)
start(Length) ->
	register(head, spawn(proRing, ring_loop, [0])),
	head!{start, Length-1}.

message(Message, Ammount) -> head!{message, Message, Ammount}.

stop() -> head!stop.

ring_loop(Pid) ->
	receive
		{start, Length} ->
			NewPid = spawn(proRing, ring_loop, [0]),
			NewPid!{next, Length},
			io:format(  "I'm: ~p, I'm Head, I point at: ~p~n", [ pid_to_list( self() ), NewPid ]  ),
			ring_loop(NewPid);

		{next, 1} ->
			io:format(  "I'm: ~p, I'm Tail, I point at: ~p~n", [ pid_to_list( self() ), whereis(head) ]  ),
			ring_loop(whereis(head));

		{next, Length} ->
			NewPid = spawn(proRing, ring_loop, [0]),
			NewPid!{next, Length-1},
			io:format(  "I'm: ~p, I'm Body, I point at: ~p~n", [ pid_to_list( self() ), NewPid ]  ),
			ring_loop(NewPid);

		{message, _Message, 0} -> ring_loop(Pid);

		% Recursive message sent accross the ring, if its the tail (the one that points to head) it decreases ammount
		{message, Message, Ammount} ->
			case whereis(head) of
				Pid ->
					io:format("I'm : ~p, I point at: ~p, I got the message: ~p~n", [pid_to_list(self()), pid_to_list(Pid), Message]),
					Pid!{message, Message, Ammount-1},
					ring_loop(Pid);
				_Other ->
					io:format("I'm: ~p, I point at: ~p, I got the message: ~p~n", [pid_to_list(self()), pid_to_list(Pid), Message]),
					Pid!{message, Message, Ammount},
					ring_loop(Pid)
			end;

		stop -> Pid!stop
	end.

















	
