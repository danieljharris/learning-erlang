-module(das_node).
-export([create/0, address_loop/0]).

-include("nodes.hrl").

-vsn(1.0).

% Exercise 11-1: Distributed Associative Store (Main Nodes)

create() -> register(address_loop, spawn(das_node, address_loop, [])).

address_loop() ->
  receive
    {link, Node} ->
      net_kernel:connect(Node),
      monitor_node(Node, true),
      {address_loop, Node} ! {link_node, node()},
      address_loop();

    {link_node, Node} ->
      % net_kernel:connect(Node),
      monitor_node(Node, true),
      address_loop();

    {add, Address, Nickname} ->
      {db_server, ?DB_NODE} ! {write, Address, Nickname},
      address_loop();

    {remove, Address} ->
      {db_server, ?DB_NODE} ! {delete, Address},
      address_loop();

    {lookup, Address, Pid} ->
      clear_mailbox(),
      {db_server, ?DB_NODE} ! {read, Address, self()},
      receive
        Reply -> Pid ! Reply
      after 1000 -> {error, timeout} 
      end,
      address_loop();
    stop -> ok

  after 30000 -> {error, timeout}
  end.


clear_mailbox() ->
    receive
        _Any ->
            clear_mailbox()
    after 0 ->
        ok
    end.
