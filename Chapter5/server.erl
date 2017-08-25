-module(server).
-export([start/2, stop/1, call/2]).
-export([init/1]).

start(Name, Data) ->
	Pid = spawn(server, init,[Data]),
	register(Name, Pid),
	ok.

stop(Name) ->
	Name ! {stop, self()},
	receive {reply, Reply} -> Reply end.

call(Name, Msg) ->
	Name ! {request, self(), Msg},
	receive {reply, Reply} -> Reply end.

reply(To, Msg) ->
	To ! {reply, Msg}.

init(Data) -> loop(initialize(Data)).

loop(State) ->
	receive
		{request, From, Msg} ->
			{Reply,NewState} = handle_msg(Msg, State),
			reply(From, Reply),
			loop(NewState);
		{stop, From} ->
			reply(From, terminate(State))
	end.







initialize(Data) -> Data. 
handle_msg({Type, Message}, State) ->
	case State of
		open ->
			case Type of
				msg  -> io:format("Open Message: ~p~n", [Message]),
					{ok, open};
				swop ->
					io:format("Swop: ~p~n", [Message]),
					{ok, Message}
			end;
		closed ->
			case Type of
				msg  -> io:format("Closed Message: ~p~n", [Message]),
					{ok, closed};
				swop ->
					io:format("Swop: ~p~n", [Message]),
					{ok, Message}
			end
	end.
terminate(State) -> io:format("Terminated: ~p~n", [State]).

