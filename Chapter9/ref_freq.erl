-module(ref_freq).
-export([start/0, stop/0, allocate/0, deallocate/1]).
-export([init/0]).

-vsn(3.0).

%% These are the start functions used to create and
%% initialize the server.

start() ->
	register(changeFreq, spawn(ref_freq, init, [])).

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
	Ref = make_ref(),
	changeFreq ! {request, {Ref, self()}, Message},
	receive
		{reply, Ref, Reply} -> Reply;
		_ -> {error, invalid_reference}
	end.



%% The Main Loop
loop(Frequencies) ->
	receive
		{request, {Ref, Pid}, allocate} ->
			{NewFrequencies, Reply} = allocate(Frequencies, Pid),
			reply({Ref, Pid}, Reply),
			loop(NewFrequencies);

		{request, {Ref, Pid}, {deallocate, Freq}} ->
			{NewFrequencies, Reply} = deallocate(Frequencies, Freq, Pid),
			reply({Ref, Pid}, Reply),
			loop(NewFrequencies);

		{request, {Ref, Pid}, stop} ->
			case Frequencies of
			    {_, [] = _Allocated} ->
			        reply({Ref, Pid}, ok);
			    {_, _Allocated} ->
			        reply({Ref, Pid}, {error, frequencies_still_allocated}),
			        loop(Frequencies)
			end

		% {request, Pid, stop} ->
			% {_, Allocated} = Frequencies,
			% case Allocated == [] of
			% 	true -> reply(Pid, ok);
			% 	false ->
			% 		reply(Pid, {error, frequencies_still_allocated}),
			% 		loop(Frequencies)
			% end
	end.

reply({Ref, Pid}, Reply) -> Pid ! {reply, Ref, Reply}.



%% The Internal Help Functions used to allocate and
%% deallocate frequencies.
allocate({[] = _Free, _Allocated} = Frequencies, _Pid) ->
    { Frequencies, {error, no_frequency} };

% allocate({[], Allocated}, _Pid) ->
% 	{{[], Allocated}, {error, no_frequency}};


allocate({[Freq|Free], Allocated}, Pid) ->
	case count(Pid, Allocated) of
		Count when Count < 3 ->
			{ { Free, [ {Freq, Pid} | Allocated ] }, {ok, Freq} };
		_Count ->
			{ {[Freq|Free], Allocated}, {error, frequencies_already_allocated} }
	end.


deallocate({_Free, [] = _Allocated} = Frequencies, _Freq, _Pid) ->
    { Frequencies, {error, no_used_frequences} };

% deallocate({Free, []}, _) ->
% 	{ {Free, []}, {error, no_used_frequences} };

deallocate({Free, Allocated} = Frequencies, Freq, Pid) ->
	case lists:keyfind(Freq, 1, Allocated) of
		false ->
			{ Frequencies, {error, frequence_not_used} };
		{Freq, Pid} ->
			NewAllocated = lists:keydelete(Freq, 1, Allocated),
			{ { [Freq|Free], NewAllocated }, ok};
		_Other ->
			{Frequencies, {error, access_denied}}
	end.



count(Needle, Haystack) -> count(Needle, Haystack, 0).

count(_, [], Count) -> Count;
count(X, [{_, X}|Rest], Count) -> count(X, Rest, Count+1);
count(X, [_|Rest], Count) -> count(X, Rest, Count).