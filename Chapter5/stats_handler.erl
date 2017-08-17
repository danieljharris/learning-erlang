-module(stats_handler).
-export([init/1, terminate/1, handle_event/2]).

init(Db) -> Db.
terminate(Db) -> {db, Db}.

handle_event({Type, _Id, Description}, Db) ->
	case lists:keysearch( {Type, Description}, 1, Db ) of
		false ->
			[ {{Type, Description}, 1} | Db ];
		{ value, { {Type, Description}, Data }} ->
			lists:keyreplace(  {Type, Description}, 1, Db, { {Type, Description}, Data + 1}  )
	end.
