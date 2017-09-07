-module(proxy).
-export([server/0, wait_connect/2, get_request/2]).


server() ->
  inets:start(),
  {ok, ListenSocket} = gen_tcp:listen(1500, [binary, {active, false}]),
  wait_connect(ListenSocket,0).

wait_connect(ListenSocket, Count) ->
  {ok, Socket} = gen_tcp:accept(ListenSocket),
  spawn(?MODULE, wait_connect, [ListenSocket, Count+1]),
  get_request(Socket, Count).

get_request(Socket, Count) ->
  case gen_tcp:recv(Socket, 0, 5000) of
    {ok, Binary} ->
      handle([Binary], Count, Socket);
    {error, closed} ->
      ok
  end.

handle([<<_Get:4/binary, Tail/binary>>], _Count, Socket) ->
  Url = extract_url(Tail, []),

  {ok, {{_HttpVersion, 200, "OK"}, Header, Body}} = httpc:request(Url),

  send(Socket, Header),
  send(Socket, Body),
  io:format("~p~n~n", [Url]).

extract_url(<< " ", _Tail/binary>>, Acc) ->
  lists:reverse(lists:concat(Acc));

extract_url(<<Head:1/binary, Tail/binary>>, Acc) ->
  extract_url(Tail, [erlang:binary_to_list(Head) | Acc]).

send(Socket, <<Chunk:100/binary, Rest/binary>>) ->
  gen_tcp:send(Socket, Chunk),
  send(Socket, Rest);

send(Socket, Rest) ->
  gen_tcp:send(Socket, Rest).
