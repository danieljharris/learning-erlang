-module(call_count).
-export([test/0]).
-export([counter/1]).

-define(COUNT_CALL(Module, Function), (counter ! {count, Module, Function} )).


% Exercise 7-7: Counting Calls

test() ->
  counter_start(),

  foo(),
  bar(),
  foo(),
  foo(),
  bar(),

  Result = counter_read(),
  counter_stop(),
  Result.


% Example Functions
foo() ->
  ?COUNT_CALL(call_count, foo),
  ok.

bar() ->
  ?COUNT_CALL(call_count, bar),
  ok.



% Counting Functions
counter_start() ->
  register(counter, spawn(call_count, counter, [ [] ])),
  ok.

counter_stop() ->
  counter ! stop.

counter_read() ->
  counter ! {read, self()},
  receive
    Reply -> Reply
  after 1000 -> {error, timeout}
  end.

% Counter Loop
counter(Accumulator) ->
   receive 
      {read, Pid} ->
        Pid!Accumulator,
        counter(Accumulator);

      {count, Module, Function} ->
        case lists:keyfind({Module, Function}, 1, Accumulator) of
          false ->
            counter([{{Module, Function}, 1} | Accumulator]);

          {_, Count} -> 
            NewList = lists:keydelete({Module, Function}, 1, Accumulator),
            counter([{{Module, Function}, Count + 1} | NewList])
        end;

      stop ->
        ok
   end.
