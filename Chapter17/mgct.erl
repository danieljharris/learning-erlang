-module(mgct).
-export([measure/3, averageT/1, averageNT/1]).
-export([loop/2]).


% Exercise 17-1: Measuring Garbage Collection Times

measure(Module, Function, Args) ->
  LoopPid = spawn(mgct, loop, [{minor, 0, 0}, {major, 0, 0}]),

  Pid = spawn(Module, Function, [Args]),
  erlang:trace(Pid, true, [garbage_collection, {tracer, LoopPid}]),
  ok.


loop(Minor, Major) ->
  receive
    % Minor -------------------
    {trace, _, gc_minor_start, _} ->
      {minor, _IStart, IEnd} = Minor,
      loop({minor, erlang:timestamp(), IEnd}, Major);

    {trace, _, gc_minor_end, _} ->
      {minor, IStart, _IEnd} = Minor,
      loop({minor, IStart, erlang:timestamp()}, Major);
    
    % Major -------------------
    {trace, _, gc_major_start, _} ->
      {major, _JStart, JEnd} = Major,
      loop(Minor, {major, erlang:timestamp(), JEnd});

    {trace, _, gc_major_end, _} ->
      {major, JStart, _JEnd} = Major,
      Now = erlang:timestamp(),
      display_gc(Minor, {major, JStart, Now}),
      loop(Minor, {major, JStart, Now})

  after 5000 ->
    {error, timeout}
  end.

display_gc({minor, IStart, IEnd}, {major, JStart, JEnd}) ->
  io:format("Gc minor took: ~p mircoseconds~n", [timer:now_diff(IEnd, IStart)]),
  io:format("Gc major took: ~p mircoseconds~n", [timer:now_diff(JEnd, JStart)]).



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
