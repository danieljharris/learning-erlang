-module(proRing).
% -export([ring_start/2]).
% -export([ring_loop/4]).
-export([ring/3]).
-export([ring/4, ring_loop/3]).

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
% The first process will send the specified amount of messages
% It seems to break sometimes when its run? But runs as it should most of the time
ring(Length, M, Message) -> ring(0, Length, M, Message).

ring(F_Pid, Length, M, Message) when Length == 1 -> F_Pid!{message, Message}, ring_loop(false, F_Pid, M);
ring(F_Pid, Length, M, Message) when F_Pid  == 0 -> Pid = spawn(proRing, ring, [self(), Length -1, M, Message]), ring_loop(true, Pid, M);
ring(F_Pid, Length, M, Message) when F_Pid  /= 0 -> Pid = spawn(proRing, ring, [F_Pid,  Length -1, M, Message]), ring_loop(false, Pid, M).


ring_loop(First, Pid, M) ->
	receive
		{message, _} when M == 0 -> catch Pid!stop;

		{message, Message} when First ->
			io:format("I'm: ~p, I point at: ~p~n", [pid_to_list(self()), pid_to_list(Pid)]),
			Pid!{message, Message},
			ring_loop(First, Pid, M-1);

		{message, Message} when not First ->
			io:format("I'm: ~p, and I got the message: ~p~n", [pid_to_list(self()), Message]),
			Pid!{message, Message},
			ring_loop(First, Pid, M);

		stop -> catch Pid!stop, ok

	after 1000 -> timeout
	end.
