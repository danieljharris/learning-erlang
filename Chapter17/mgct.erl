-module(mgct).
-export([measure/3, averageT/1, averageNT/1]).
-export([loop/2]).

% Exercise 17-1: Measuring Garbage Collection Times

measure(Module, Function, Args) ->
  LoopPid = spawn(mgct, loop, [{minor, 0}, {major, 0}]),

  Pid = spawn(Module, Function, [Args]),
  erlang:trace(Pid, true, [garbage_collection, {tracer, LoopPid}]),
  ok.


loop(Minor, Major) ->
  receive
    % Minor -------------------
    {trace, _, gc_minor_start, _} ->
      {minor, _IStart} = Minor,
      loop({minor, erlang:timestamp()}, Major);

    {trace, _, gc_minor_end, _} ->
      Now = erlang:timestamp(),
      {minor, IStart} = Minor,
      display_gc({minor, IStart}, Now),
      loop({minor, IStart}, Major);
    % Minor -------------------

    % Major -------------------
    {trace, _, gc_major_start, _} ->
      {major, _JStart} = Major,
      loop(Minor, {major, erlang:timestamp()});

    {trace, _, gc_major_end, _} ->
      Now = erlang:timestamp(),
      {major, JStart} = Major,
      display_gc({major, JStart}, Now),
      loop(Minor, {major, JStart})
    % Major -------------------

  after 5000 ->
    {error, trace_timeout}
  end.

display_gc({Type, Start}, End) ->
  io:format("Gc ~p took: ~p mircoseconds~n", [Type, timer:now_diff(End, Start)]).



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
