-module(proxy).
-export([server/0, wait_connect/2, get_request/2]).


server() ->
  {ok, ListenSocket} = gen_tcp:listen(1501, [binary, {active, false}]),
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

% the http module is no longer used and I could not get the newer httpc module
% to return the site in the same format as the http module would have 

handle([<<_Get:4/binary, Tail/binary>>], _Count, Socket) ->
  Url = extract_url(Tail, []),
  % {ok, Site} = httpc:request(Url),
  % gen_tcp:send(Socket, Site).
  io:format("~p~n", [Url]).


extract_url(<< " ", _Tail/binary>>, Acc) ->
  lists:reverse(lists:concat(Acc));

extract_url(<<Head:1/binary, Tail/binary>>, Acc) ->
  extract_url(Tail, [erlang:binary_to_list(Head) | Acc]).
