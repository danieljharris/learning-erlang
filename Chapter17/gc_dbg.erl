-module(gc_dbg).
-export([measure/3, averageT/1, averageNT/1]).
-export([do_measure/3]).

% Exercise 17-2: Garbage Collection Using dbg

measure(Module, Function, Args) ->
  spawn(gc_dbg, do_measure, [Module, Function, Args]),
  ok.

do_measure(Module, Function, Args) ->
  HandlerFun =
    fun
      % Minor -------------------
      ({trace, _, gc_minor_start, Start}, _) ->
        {minor, erlang:timestamp(), Start};

      ({trace, _, gc_minor_end, End}, {minor, IStart, IStartData}) ->
        Now = erlang:timestamp(),

        % Old Heap
        {_, {_,OHS}} = lists:keysearch(old_heap_size, 1, IStartData),
        {_, {_,OHE}} = lists:keysearch(old_heap_size, 1, End),
        % Heap
        {_, {_,HS}} = lists:keysearch(heap_size, 1, IStartData),
        {_, {_,HE}} = lists:keysearch(heap_size, 1, End),

        display_gc({minor, IStart}, Now, OHS-OHE, HS-HE),
        ok;
      % Minor -------------------

      % Major -------------------
      ({trace, _, gc_major_start, Start}, _) ->
        {major, erlang:timestamp(), Start};

      ({trace, _, gc_major_end, End}, {major, JStart, JStartData}) ->
        Now = erlang:timestamp(),

        % Old Heap
        {_, {_,OHS}} = lists:keysearch(old_heap_size, 1, JStartData),
        {_, {_,OHE}} = lists:keysearch(old_heap_size, 1, End),
        % Heap
        {_, {_,HS}} = lists:keysearch(heap_size, 1, JStartData),
        {_, {_,HE}} = lists:keysearch(heap_size, 1, End),

        display_gc({major, JStart}, Now, OHS-OHE, HS-HE),
        ok
      % Major -------------------

    end,

  dbg:tracer(process, {HandlerFun, null}),
  dbg:p(self(), [garbage_collection]),

  Result = apply(Module, Function, [Args]),
  dbg:stop(),
  Result.


display_gc({Type, Start}, End, OldHeap, Heap) ->
  io:format("Gc ~p (Old Heap) freed: ~p~n", [Type, OldHeap]),
  io:format("Gc ~p (Heap) freed: ~p~n", [Type, Heap]),
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
