%% @author Daniel Harris

-module(ref_freq).
% -compile(export_all).
-export([start/0, stop/0, allocate/0, deallocate/1]).
-export([init/0]).


-type(frequency()    :: integer() ).


-spec(start() -> true).
%% @doc Starts the server.
%% Use {@link stop/0. 'stop/0'} to stop it.
start() ->
  register(changeFreq, spawn(ref_freq, init, [])).

-spec(stop() -> ok | {error, frequencies_still_allocated} | {error, invalid_reference}).
%% @doc Stops the server.
%% Use {@link start/0. 'start/0'} to start it back up.
stop() -> call(stop).


%% @doc Initialize the server.
init() ->
	Frequencies = {get_frequencies(), []},
	loop(Frequencies).

-spec(get_frequencies() -> list()).
%% Hard Coded
get_frequencies() -> [10,11,12,13,14,15].


-spec(allocate() ->
  integer() |
  {error, no_frequency} |
  {error, frequencies_already_allocated}
).
%% @doc Allocates a frequencie to the caller
allocate() 		   -> call(allocate).


-spec(deallocate( frequency() ) ->
  ok |
  {error, no_used_frequencys} |
  {error, frequency_not_used} |
  {error, access_denied}
).
%% @doc De-allocates a frequencie from the caller
deallocate(Freq) -> call({deallocate, Freq}).


-spec(call(any()) ->
  any()|
  {error, invalid_reference}
).
% All message passing and receiving is hidden in the call function.
call(Message) ->
	Ref = make_ref(),
	changeFreq ! {request, {Ref, self()}, Message},
	receive
		{reply, Ref, Reply} -> Reply;
		_ -> {error, invalid_reference}
	end.

% The Main Loop.
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
	end.

-spec(reply( tuple(), any() ) -> tuple()).
reply({Ref, Pid}, Reply) -> Pid ! {reply, Ref, Reply}.





-spec(allocate( tuple(), pid() ) ->
  {tuple(), {ok, frequency()}} |
  {tuple(), {error, no_frequency}} |
  {tuple(), {error, frequencies_already_allocated}}
).
allocate({[] = _Free, _Allocated} = Frequencies, _Pid) ->
    { Frequencies, {error, no_frequency} };

allocate({[Freq|Free], Allocated}, Pid) ->
	case count(Pid, Allocated) of
		Count when Count < 3 ->
			{ { Free, [ {Freq, Pid} | Allocated ] }, {ok, Freq} };
		_Count ->
			{ {[Freq|Free], Allocated}, {error, frequencies_already_allocated} }
	end.


-spec(deallocate( tuple(), frequency(), pid() ) ->
  {tuple(), ok} |
  {tuple(), {error, no_used_frequencys}} |
  {tuple(), {error, frequency_not_used}} |
  {tuple(), {error, access_denied}}
).
deallocate({_Free, [] = _Allocated} = Frequencies, _Freq, _Pid) ->
    { Frequencies, {error, no_used_frequencys} };

deallocate({Free, Allocated} = Frequencies, Freq, Pid) ->
	case lists:keyfind(Freq, 1, Allocated) of
		false ->
			{ Frequencies, {error, frequency_not_used} };
		{Freq, Pid} ->
			NewAllocated = lists:keydelete(Freq, 1, Allocated),
			{ { [Freq|Free], NewAllocated }, ok};
		_Other ->
			{Frequencies, {error, access_denied}}
	end.


-spec( count( pid(), list() ) -> integer() ).
count(Needle, Haystack) -> count(Needle, Haystack, 0).

count(_, [], Count) -> Count;
count(X, [{_, X}|Rest], Count) -> count(X, Rest, Count+1);
count(X, [_|Rest], Count) -> count(X, Rest, Count).
