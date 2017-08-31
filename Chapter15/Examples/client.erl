-module(client).
-export([client/1, send/2]).

client(Data) ->
  {ok, Socket} = gen_tcp:connect({127,0,0,1}, 1234, [binary, {packet, 0}]),
  send(Socket, Data),
  ok = gen_tcp:close(Socket).


send(Socket, <<Chunk:100/binary, Rest/binary>>) ->
  gen_tcp:send(Socket, Chunk),
  send(Socket, Rest);

send(Socket, Rest) ->
  gen_tcp:send(Socket, Rest).
