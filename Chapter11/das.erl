-module(das).
-export([open/0, close/0]).
-export([add/2, remove/1, lookup/1]).

-vsn(1.0).

-include("nodes.hrl").

% Exercise 11-1: Distributed Associative Store (Interface & Load Balancer)

open() ->
  spawn(?BALANCE_NODE, balance_node, start, []),

  spawn(?DB_NODE, db_node, start, []),

  spawn(?NODE_ONE, das_node, create, []),
  spawn(?NODE_TWO, das_node, create, []),

  {balancer, ?BALANCE_NODE} ! {link, ?DB_NODE},
  {balancer, ?BALANCE_NODE} ! {link, ?NODE_ONE},
  {balancer, ?BALANCE_NODE} ! {link, ?NODE_TWO},

  ok.

close() ->
  {balancer,      ?BALANCE_NODE}  ! stop,
  {address_loop,  ?NODE_ONE}      ! stop,
  {address_loop,  ?NODE_TWO}      ! stop,
  {db_server,     ?DB_NODE}       ! stop,
  ok.

add(Address, Nickname) -> {balancer, ?BALANCE_NODE} ! {add, Address, Nickname}.
remove(Address) -> {balancer, ?BALANCE_NODE} ! {remove, Address}.

lookup(Address)	->
  clear_mailbox(),
  {balancer, ?BALANCE_NODE} ! {lookup, Address, self()},
  receive Reply -> Reply after 1000 -> {error, timeout} end.


clear_mailbox() ->
    receive
      _Any ->
            clear_mailbox()
    after 0 ->
        ok
    end.
