-module(gc_dbg).
-export([measure/3, averageT/1, averageNT/1]).
-export([loop/0]).

% Exercise 17-2: Garbage Collection Using dbg


measure(Module, Function, Args) ->
  register(test ,spawn(Module, Function, [Args])),

  HandlerFun =
    fun

      ({trace, Pid, gc_minor_start, Start}, _) ->
        Start;
      ({trace, Pid, gc_minor_end, End}, Start) ->
        {_, {_,OHS}} = lists:keysearch(old_heap_size, 1, Start),
        {_, {_,OHE}} = lists:keysearch(old_heap_size, 1, End),
        io:format("Old heap size delta after gc:~w~n",[OHS-OHE]),
        {_, {_,HS}} = lists:keysearch(heap_size, 1, Start),
        {_, {_,HE}} = lists:keysearch(heap_size, 1, End),
        io:format("Heap size delta after gc:~w~n",[HS-HE])
    end,

  dbg:tracer(process, {HandlerFun, null}).
  dbg:p(self(), [garbage_collection]).

  % List = lists:seq(1,1000).
  % RevList = lists:reverse(List).

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
