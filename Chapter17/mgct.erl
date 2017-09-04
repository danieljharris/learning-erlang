-module(mgct).
-export([measure/3, averageT/1, averageNT/1]).
-export([loop/0]).


% Exercise 17-1: Measuring Garbage Collection Times
% I've tried to get this exercise to work but I cant get the tracer
% to trace garbage_collection

% There is an example on page 362 that shows how to trace garbage_collection
% but this example doesent work when I do it
% (There is never any traces done on garbage_collection)


measure(Module, Function, Args) ->
  LoopPid = spawn(mgct, loop, []),

  register(test ,Pid = spawn(Module, Function, [Args])),
  % erlang:trace(Pid, false, [all]),
  erlang:trace(Pid, true, [garbage_collection, {tracer, LoopPid}]),
  test ! start,
  % erlang:trace_pattern({'_', '_', '_'}, true, [local]),
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
averageT(List) ->
  receive
    Message ->
      io:format("I Got: ~p~n", [Message]),
      loop()
  after 1000 ->
    io:format("Error: ~p~n", [{error, timeout}])
  end,
  sum(List) / len(List).

sum([]) -> 0;
sum([Head | Tail]) -> Head + sum(Tail).
len([]) -> 0;
len([_ | Tail]) -> 1 + len(Tail).

% Non-tail-recursive function
averageNT(List) -> average_acc(List, 0,0).
average_acc([], Sum, Length) -> Sum / Length;
average_acc([H | T], Sum, Length) -> average_acc(T, Sum + H, Length + 1).
