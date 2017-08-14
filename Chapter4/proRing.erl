-module(proRing).
-export([ring/2]).

%%Exercise 4-2: The Process Ring
%Not sure what was meant by 'number of messages'
ring(F_Pid, Length) ->
	if
		Length == 1 -> Pid = F_Pid;
		F_Pid  == 0 -> Pid = spawn(proRing, ring, [self(), Length -1]);
		F_Pid  /= 0 -> Pid = spawn(proRing, ring, [F_Pid, Length -1])
	end,
	receive
		stop ->
			true;
		loop ->
			io:format("I'm: ~p, I point at: ~p~n", [pid_to_list(self()), pid_to_list(Pid)]),
			Pid!loop
	end.