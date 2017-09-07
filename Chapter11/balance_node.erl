-module(balance_node).
-export([start/1, balancer/1]).

-include("nodes.hrl").

-vsn(1.0).

% Exercise 11-1: Distributed Associative Store (Main Nodes)

start(StartNode) ->
  event_manager:start(node_logger, [{log_handler, "NodeLog"}]),
  register(balancer, spawn(balance_node, balancer, [StartNode])).

stop() ->
  event_manager:stop(node_logger),
  ok.

balancer(LastDB) ->
  case LastDB of
    ?DB_NODE1 -> NextDB = ?DB_NODE2;
    ?DB_NODE2 -> NextDB = ?DB_NODE1
  end,

  receive
    {add, Address, Nickname} ->
      to_all_db_nodes({write, Address, Nickname}),
      event_manager:send_event(node_logger, {add, {Address, Nickname}, NextDB}),
      balancer(NextDB);

    {remove, Address} ->
      to_all_db_nodes({db_server, NextDB} ! {delete, Address}),
      event_manager:send_event(node_logger, {remove, {Address}, NextDB}),
      balancer(NextDB);

    {lookup, Address, Pid} ->
      {db_server, NextDB} ! {read, Address, Pid},
      event_manager:send_event(node_logger, {lookup, {Address}, NextDB}),
      balancer(NextDB);

    stop -> stop(), ok
  end.

to_all_db_nodes(Message) ->
  {db_server, ?DB_NODE1} ! Message,
  {db_server, ?DB_NODE2} ! Message,
  ok.
