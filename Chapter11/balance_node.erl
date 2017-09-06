-module(balance_node).
-export([start/0, balancer/1]).

-include("nodes.hrl").

-vsn(1.0).

% Exercise 11-1: Distributed Associative Store (Main Nodes)

start() ->
  event_manager:start(node_logger, [{log_handler, "NodeLog"}]),
  register(balancer, spawn(balance_node, balancer, [?NODE_ONE])).

stop() ->
  event_manager:stop(node_logger).


balancer(LastNode) ->
  case LastNode of
    ?NODE_ONE -> NextNode = ?NODE_TWO;
    ?NODE_TWO -> NextNode = ?NODE_ONE
  end,

  receive
    {add, Address, Nickname} ->
      {address_loop, NextNode} ! {add, Address, Nickname},
      event_manager:send_event(node_logger, {add, {Address, Nickname}, NextNode}),
      balancer(NextNode);

    {remove, Address} ->
      {address_loop, NextNode} ! {remove, Address},
      event_manager:send_event(node_logger, {remove, {Address}, NextNode}),
      balancer(NextNode);

    {lookup, Address, Pid} ->
      event_manager:send_event(node_logger, {lookup, {Address}, NextNode}),
      {address_loop, NextNode} ! {lookup, Address, self()},
      receive
        Reply -> Pid ! Reply
      after 1000 -> {error, timeout}
      end,
      balancer(NextNode);

    stop -> stop(), ok
  end.
