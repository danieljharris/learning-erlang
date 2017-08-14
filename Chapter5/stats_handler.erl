-module(stats_handler).
-export([init/1, terminate/1, handle_event/2]).

init(Db) -> Db.
terminate(Db) -> {db, Db}.

handle_event(Event, Db) ->
	case lists:keysearch( Event, 1, Db ) of
		false ->
			{ok, Db ++ [{Event, 1}]};
		{ Event, Data } ->
			lists:keyreplace(Event, 1, Db, {Event, Data + 1})
	end.