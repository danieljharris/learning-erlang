-module(my_db_gen).
-export([start_link/0, stop/0]).
-export([write/2, delete/1, read/1, match/1]).

-behavior(gen_server).
-export([init/1, terminate/2, handle_call/3, handle_cast/2, handle_info/2]).

%% Exercise 12-1: Database Server Revisited

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() -> gen_server:cast(?MODULE, stop).


%% Interface
write  (Key, Element) -> gen_server:call(?MODULE, {write,  {Key, Element }}).
delete (Key)          -> gen_server:call(?MODULE, {delete, Key           }).
read   (Key)          -> gen_server:call(?MODULE, {read,   Key           }).
match  (Element)      -> gen_server:call(?MODULE, {match,  Element       }).

%% Callback Functions
init(_) ->
  {ok, []}.

terminate(_Reason, _LoopData) ->
  ok.

handle_cast(stop, LoopData) ->
  {stop, normal, LoopData}.

handle_call({write, Data}, _From, LoopData) ->
  Reply = ok,
  NewLoopData = [Data | LoopData],
  {reply, Reply, NewLoopData};

handle_call({delete, Message}, _From, LoopData) ->
  Reply = ok,
  NewLoopData = lists:keydelete(Message, 1, LoopData),
  {reply, Reply, NewLoopData};

handle_call({read, Message}, _From, LoopData) ->
  Result = lists:keyfind(Message, 1, LoopData),
  Reply = case Result of
  	false -> {error, instance};
  	{_Key, Element} -> {ok, Element}
  end,
  {reply, Reply, LoopData};

handle_call({match, Message}, _From, LoopData) ->
  Reply = [Key || {Key, Element} <- LoopData, Element == Message ],
  {reply, Reply, LoopData}.

handle_info(_Msg, LoopData) ->
  {noreply, LoopData}.
