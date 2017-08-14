-module(changeFreq).
-export([start/0, stop/0, allocate/0, deallocate/1]).
-export([init/0]).

%% These are the start functions used to create and
%% initialize the server.

start() ->
	register(changeFreq, spawn(changeFreq, init, [])).

init() ->
	Frequencies = {get_frequencies(), []},
	loop(Frequencies).

% Hard Coded
get_frequencies() -> [10,11,12,13,14,15].



%% The client Functions
stop() 			 -> call(stop).

allocate() 		 -> call(allocate).

deallocate(Freq) -> call({deallocate, Freq}).

%% We hide all message passing and the message
%% protocol in a functional interface.
call(Message) ->
	changeFreq ! {request, self(), Message},
	receive
		{reply, Reply} -> Reply
	end.




%% The Main Loop
loop(Frequencies) ->
	receive
		{request, Pid, allocate} ->
			{NewFrequencies, Reply} = allocate(Frequencies, Pid),
			reply(Pid, Reply),
			loop(NewFrequencies);

		{request, Pid , {deallocate, Freq}} ->
			{NewFrequencies, Reply} = deallocate(Frequencies, Freq),
			reply(Pid, Reply),
			loop(NewFrequencies);

		{request, Pid, stop} ->
			{_, Allocated} = Frequencies,
			case Allocated == [] of
				true -> reply(Pid, ok);
				false ->
					reply(Pid, {error, frequencies_still_allocated}),
					loop(Frequencies)
			end
	end.

reply(Pid, Reply) -> Pid ! {reply, Reply}.



%% The Internal Help Functions used to allocate and
%% deallocate frequencies.
allocate({[], Allocated}, _Pid) ->
	{{[], Allocated}, {error, no_frequency}};

allocate({[Freq|Free], Allocated}, Pid) ->
	case (count(Pid, Allocated) < 3) of
		true -> { { Free, [ {Freq, Pid} | Allocated ] }, {ok, Freq} };
		false  -> { {[Freq|Free], Allocated}, {error, frequencies_already_allocated} }
	end.


deallocate({Free, []}, _) ->
	{ {Free, []}, {error, no_used_frequences} };

deallocate({Free, Allocated}, Freq) ->
	case lists:keyfind(Freq, 1, Allocated) of
		false -> { {Free, Allocated}, {error, frequence_not_used} };
		_Other ->
			NewAllocated = lists:keydelete(Freq, 1, Allocated),
			{ { [Freq|Free], NewAllocated }, ok}
	end.



count(Needle, Haystack) -> count(Needle, Haystack, 0).

count(_, [], Count) -> Count;
count(X, [{_, X}|Rest], Count) -> count(X, Rest, Count+1);
count(X, [_|Rest], Count) -> count(X, Rest, Count).























