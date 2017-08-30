-module(my_db_sup).

-behavior(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
  UsrChild = {
    my_db_gen, {my_db_gen, start_link, []}, permanent, 30000, worker, [my_db_gen]
    },
  {ok,{{one_for_all, 5, 3600}, [UsrChild]}}.
