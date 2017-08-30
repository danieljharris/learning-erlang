-module(otp_testing).
-export([start_link/1, init/1, test/0]).

-vsn(1.0).

test() ->
  ok.



start_link(FileName) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, FileName, []).

init(FileName) ->
  usr_db:create_tables(FileName), usr_db:restore_backup(),
  {ok, null}.


set_status(CustId, Status) when Status==enabled; Status==disabled->
  gen_server:call(?MODULE, {set_status, CustId, Status}).

delete_disabled() ->
  gen_server:call(?MODULE, delete_disabled).


handle_call({set_status, CustId, Status}, _From, LoopData) ->
  Reply = case usr_db:lookup_id(CustId) of
    {ok, Usr} ->
      usr_db:update_usr(Usr#usr{status=Status});

    {error, instance} ->
      {error, instance}
    end,
  {reply, Reply, LoopData};

handle_call(delete_disabled, _From, LoopData) ->
  {reply, usr_db:delete_disabled(), LoopData}.




stop() ->
  gen_server:cast(?MODULE, stop).

handle_cast(stop, LoopData) ->
  {stop, normal, LoopData}.

terminate(_Reason, _LoopData) ->
  usr_db:close_tables().
