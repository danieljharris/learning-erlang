-module(gc_dbg).
-export([measure/3, averageT/1, averageNT/1]).
-export([loop/0]).

% Exercise 17-2: Garbage Collection Using dbg

% Was attempting this exercise and came accross the same problem as before
% it wont let me do any traces on garbage_collection

% The example on page 372 is meant to show how to trace garbage_collection
% but when I follow the example it crashes


measure(Module, Function, Args) ->
  % LoopPid = spawn(mgct, loop, []),

  register(test ,spawn(Module, Function, [Args])),
  % erlang:trace(Pid, false, [all]),

  % PortFun = dbg:trace_port(ip, 1234),
  % dbg:trace(port, PortFun),
  % dbg:tp({Module, Function, '_'}, []),

  dbg:tracer().

  test ! start,
  ok.


loop() ->
  receive
    Message ->
      io:format("I traced: ~p~n", [Message]),
      loop()
  after 5000 ->
    io:format("Error: ~p~n", [{error, timeout}]),
    {error, timeout}
  end.


% Tail-recursive function
averageT(List) -> sum(List) / len(List).
sum([]) -> 0;
sum([Head | Tail]) -> Head + sum(Tail).
len([]) -> 0;
len([_ | Tail]) -> 1 + len(Tail).

% Non-tail-recursive function
averageNT(List) -> average_acc(List, 0,0).
average_acc([], Sum, Length) -> Sum / Length;
average_acc([H | T], Sum, Length) -> average_acc(T, Sum + H, Length + 1).
