-module(das).
-export([open/0, close/0]).
-export([add/2, remove/1, lookup/1]).

-vsn(1.0).

-include("nodes.hrl").

% Exercise 11-1: Distributed Associative Store (Interface & Load Balancer)

open() ->
  spawn(?DB_NODE1, db_node, start, []),
  spawn(?DB_NODE2, db_node, start, []),

  spawn(?BALANCE_NODE, balance_node, start, [?DB_NODE1]),

  ok.

close() ->
  {balancer,      ?BALANCE_NODE}  ! stop,
  {db_server,     ?DB_NODE1}      ! stop,
  {db_server,     ?DB_NODE2}      ! stop,
  ok.

add(Address, Nickname) -> {balancer, ?BALANCE_NODE} ! {add, Address, Nickname}.
remove(Address) -> {balancer, ?BALANCE_NODE} ! {remove, Address}.

lookup(Address)	->
  {balancer, ?BALANCE_NODE} ! {lookup, Address, self()},
  receive
    {error, timeout} ->
      {error, timeout};
    Reply ->
      Reply
  after 1000 -> {error, timeout}
  end.
