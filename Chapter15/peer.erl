-module(peer).
-export([start/0, connect/1, send/1, stop/0]).
-export([wait_connect/1]).
-export([loop/1]).

% Exercise 15-3: Peer to Peer

start() ->
  case whereis(peer) of
    undefined ->
      register(peer, spawn(?MODULE, loop, [[]])),
      peer ! start,
      ok;
    _Other ->
      {error, already_started}
  end.

connect(IpAddress) ->
  case catch(peer ! {connect, IpAddress}) of
    {'EXIT', _} -> {error, not_connected};
    _Other -> ok
  end.

send(Message) ->
  Key = <<227,79,123,63,70,178,97,116,26,25,98,188,32,40,7,173>>,
  IV = <<38,31,73,120,76,87,156,212,97,135,183,118,10,215,206,161>>,
  EncryptedContent = crypto:block_encrypt(aes_cfb128, Key, IV, Message),
  case catch(peer ! {send, EncryptedContent}) of
    {'EXIT', _} -> {error, not_connected};
    _Other -> ok
  end.

stop() ->
  case catch(peer ! stop) of
    {'EXIT', _} -> {error, not_started};
    _Other -> ok
  end.

loop(Socket) ->
  receive
    start ->
      case gen_tcp:listen(1234, [binary, {active, true}]) of
        {ok, ListenSocket} ->
          register(listen, spawn(?MODULE, wait_connect, [ListenSocket])),
          loop(Socket);
        {error, eaddrinuse} ->
          loop(Socket)
      end;

    {connect, IpAddress} ->
      io:format("Connecting~n", []),
      {ok, NewSocket} = gen_tcp:connect(IpAddress, 1234, [binary, {packet, 0}]),
      loop(NewSocket);

    {listen_establish, NewSocket} ->
      io:format("Connection Established~n", []),
      loop(NewSocket);

    {send, Message} ->
      io:format("Sending Message~n", []),
      send(Socket, Message),
      loop(Socket);

    {tcp, _From, <<Message/binary>>} ->
      Key = <<227,79,123,63,70,178,97,116,26,25,98,188,32,40,7,173>>,
      IV = <<38,31,73,120,76,87,156,212,97,135,183,118,10,215,206,161>>,
      DecryptedContent = crypto:block_decrypt(aes_cfb128, Key, IV, Message),
      io:format("Received Message~n", []),
      io:format("~p~n", [erlang:binary_to_list(DecryptedContent)]),
      loop(Socket);

    stop ->
      catch listen ! stop,
      ok
	end.

send(Socket, <<Chunk:100/binary, Rest/binary>>) ->
  gen_tcp:send(Socket, Chunk),
  send(Socket, Rest);

send(Socket, Rest) ->
  gen_tcp:send(Socket, Rest).


wait_connect(ListenSocket) ->
  case gen_tcp:accept(ListenSocket) of
    {error, closed} ->
        ok;
    {ok, Socket} ->
      gen_tcp:controlling_process(Socket, whereis(peer)),
      peer ! {listen_establish, Socket}
  end.
