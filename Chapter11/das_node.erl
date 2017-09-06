-module(das_node).
-export([create/1, address_loop/1]).

-include("nodes.hrl").

-vsn(1.0).

% Exercise 11-1: Distributed Associative Store (Main Nodes)

create(DB_Node) -> register(address_loop, spawn(das_node, address_loop, [DB_Node])).

address_loop(LastDB) ->
  case LastDB of
    ?DB_NODE1 -> NextDB = ?DB_NODE2;
    ?DB_NODE2 -> NextDB = ?DB_NODE1
  end,

  receive
    {link, Node} ->
      net_kernel:connect(Node),
      monitor_node(Node, true),
      {address_loop, Node} ! {link_node, node()},
      address_loop(NextDB);

    {link_node, Node} ->
      % net_kernel:connect(Node),
      monitor_node(Node, true),
      address_loop(NextDB);

    {add, Address, Nickname} ->
      {db_server, ?DB_NODE1} ! {write, Address, Nickname},
      {db_server, ?DB_NODE2} ! {write, Address, Nickname},
      address_loop(NextDB);

    {remove, Address} ->
      {db_server, ?DB_NODE1} ! {delete, Address},
      {db_server, ?DB_NODE2} ! {delete, Address},
      address_loop(NextDB);

    {lookup, Address, Pid} ->
      {db_server, LastDB} ! {read, Address, self()},
      receive
        Reply -> Pid ! Reply
      after 1000 -> {error, timeout}
      end,
      address_loop(NextDB);
    stop -> ok

  after 30000 -> {error, timeout}
  end.
