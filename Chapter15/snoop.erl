-module(snoop).
-export([server/0, wait_connect/2, get_request/2]).


server() ->
  {ok, ListenSocket} = gen_tcp:listen(1234, [binary, {active, false}]),
  wait_connect(ListenSocket,0).

wait_connect(ListenSocket, Count) ->
  {ok, Socket} = gen_tcp:accept(ListenSocket),
  spawn(?MODULE, wait_connect, [ListenSocket, Count+1]),
  get_request(Socket, Count).

get_request(Socket, Count) ->
  case gen_tcp:recv(Socket, 0, 50000) of
    {ok, Binary} ->
      handle([Binary], Count),
      get_request(Socket, Count);
    {error, closed} ->
      ok
  end.

handle([Binary], _Count) ->
  io:format("~p~n", [Binary]).
