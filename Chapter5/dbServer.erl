-module(dbServer).
-export([start/0, stop/0, write/2, delete/1, read/1, match/1]).
-export([loop/1]).

%%Interface
start() -> register(db, spawn(dbServer, loop, [[]])).

write	(Key, Element)	-> call(write, 	{Key, Element}	).
delete	(Key)			-> call(delete, Key				).
read	(Key)			-> call(read, 	Key				).
match	(Element)		-> call(match, 	Element			).

stop() ->
	db ! {stop, self()},
	receive {reply, Reply} -> Reply end.

call(Type, Message) ->
	db ! {Type, self(), Message},
	receive {reply, Reply} -> Reply end.

%%Backend
loop(Data) ->
	receive
		{stop, From} ->
			reply(From, ok);
		{Type, From, Msg} ->
			{Reply, NewData} = handle_msg(Type, Msg, Data),
			reply(From, Reply),
			loop(NewData)
	end.

reply(To, Msg) ->
	To ! {reply, Msg}.


handle_msg(write, Message, Data)	-> {ok, [Message | Data]};
handle_msg(delete, Message, Data)	-> {ok, lists:keydelete(Message, 1, Data)};

handle_msg(read, Message, Data)		->
	Result = lists:keyfind(Message, 1, Data),
	case Result of
		false -> {{error, instance}, Data};
		{_Key, Element} -> {{ok, Element}, Data}
	end;

handle_msg(match, Message, Data)	-> {[Key || {Key, Element} <- Data, Element == Message ], Data}.


% handle_msg(Type, Message, Data) ->
% 	case Type of
% 		write ->
% 			{Key, Element} = Message,
% 			{ok, Data ++ [{Key, Element}]};
% 		delete ->
% 			{ok, lists:keydelete(Message, 1, Data)};
% 		read ->
% 			{lists:keyfind(Message, 1, Data), Data};
% 		match ->
% 			{lists:keyfind(Message, 2, Data), Data}
% 	end.
