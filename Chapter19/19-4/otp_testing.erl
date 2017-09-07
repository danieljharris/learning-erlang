-module(otp_testing).
-export([start_link/1, init/1, set_status/2, delete_disabled/0,
         handle_call/3, stop/0, handle_cast/2, terminate/2,
         add_usr/2]).

-include("usr.hrl").

-vsn(1.0).

-behavior(gen_server).

% Interface
start_link(FileName) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, FileName, []).

add_usr(CustId, PhoneNo) ->
  gen_server:call(?MODULE, {add_usr, CustId, PhoneNo}).

set_status(CustId, Status) when Status==enabled; Status==disabled ->
  gen_server:call(?MODULE, {set_status, CustId, Status}).

delete_disabled() ->
  gen_server:call(?MODULE, delete_disabled).

stop() ->
  gen_server:cast(?MODULE, stop).



% Backend
init(FileName) ->
  usr_db:create_tables(FileName),
  usr_db:restore_backup(),
  {ok, null}.

handle_call({set_status, CustId, Status}, _From, LoopData) ->
  Reply = case usr_db:lookup_id(CustId) of
    {ok, Usr} ->
      usr_db:update_usr(Usr#usr{status=Status});

    {error, instance} ->
      {error, instance}
    end,
  {reply, Reply, LoopData};

handle_call(delete_disabled, _From, LoopData) ->
  {reply, usr_db:delete_disabled(), LoopData};

handle_call({add_usr, CustId, PhoneNo}, _From, LoopData) ->
  {reply, usr_db:add_usr(#usr{msisdn=PhoneNo, id=CustId}), LoopData}.

handle_cast(stop, LoopData) ->
  {stop, normal, LoopData}.

terminate(_Reason, _LoopData) ->
  usr_db:close_tables().
