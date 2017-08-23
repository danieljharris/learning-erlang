-module(message_ets).
-export([logger_start/0, logger_stop/0]).
-export([start/1, stop/1, init/1]).
-export([message/3, findTimes/0]).

-define(TIMEOUT, 1000).

-vsn(1.0).


% Exercise 10-3: ETS Tables for System Logging



logger_start() -> ets:new(logger, [public, named_table, {keypos, 2}]).
logger_stop() -> ets:delete(logger).

start(Name) ->
	register(Name, spawn( ?MODULE, init, [self()] )),
	receive
		started -> {ok, Name}
	after ?TIMEOUT ->
		{error, starting}
	end.

stop(Name) -> Name!stop.



message(From, Message, To) ->
	Ref = make_ref(),
	From! {message, {self(), Ref}, {Message, To} },
	receive
		{reply, Ref, Reply} -> Reply
	after
		?TIMEOUT -> {error, timeout}
	end.



reply({From, Ref}, Reply) -> From ! {reply, Ref, Reply}.



findTimes() ->
	case ets:first(logger) of
		'$end_of_table' -> {error, empty_logger};
		First ->
			[{_Type, Time, _ToFrom, _Ref}] = ets:lookup(logger, First),
			findTimesNext(First, Time, 0, 0)
	end.


findTimesNext(Last, LastTime, Count, Acc) ->
	Next = ets:next(logger,Last),
	case Next of
		'$end_of_table' -> {average_time_in_mills, Acc / Count};

		LogEntry ->
			case ets:lookup(logger, LogEntry) of
				[{sending,   T, _ToFrom, _Ref}] ->
					findTimesNext(Next, T, Count, Acc);

				[{receiving, T, _ToFrom, _Ref}] ->
					findTimesNext(Next, T, Count + 1, Acc + timer:now_diff(T, LastTime) )
			end
	end.









%% Internal Server Functions
init(Pid) ->
	Pid ! started,
	loop().

loop() ->
	receive
		{ message, From, {Message, To} } ->

			Ref = make_ref(),
			To!{get_message, {self(), Ref}, Message},

			{_, Me} = erlang:process_info(self(), registered_name),
			ets:insert(logger, {sending, erlang:timestamp(), { Me , To }, Ref}),

			Reply = get_confirmation(Ref),
			reply(From, Reply),
			loop();

		{ get_message, {FromPid, Ref} = From, _Message} ->

			{_, FromWho} = erlang:process_info(FromPid, registered_name),
			{_, Me} = erlang:process_info(self(), registered_name),
			ets:insert(logger, {receiving, erlang:timestamp(), { FromWho, Me }, Ref}),


			reply(From, message_receved),
			loop();

		stop -> ok
	end.

get_confirmation(Ref) ->
	receive
		{reply, Ref, Reply} -> Reply
	after
		?TIMEOUT -> {error, timeout}
	end.


















