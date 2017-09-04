-module(trace).
-export([test/0, loop/0]).

-vsn(1.0).

test() ->
  LoopPid = spawn(trace, loop, []),

  Pid = ping:start(),
  erlang:trace(Pid, true, [garbage_collection, timestamp, {tracer, LoopPid}]),
  % erlang:trace(Pid, true, [send, 'receive', timestamp, {tracer, LoopPid}]),
  % erlang:trace(Pid, true, [set_on_spawn, procs, {tracer, LoopPid}]),

  % erlang:trace(Pid, true, [call, {tracer, LoopPid}]),
  erlang:trace_pattern({'_', '_', '_'}, true, [local]),

  ping:send(Pid).

loop() ->
  receive
    Message ->
      io:format("I traced: ~p~n", [Message]),
      loop()
  after 1000 -> {error, timeout}
  end.
