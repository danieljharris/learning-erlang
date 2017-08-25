-module(para_macro).
-export([test/0]).

% Exercise 7-6: Parameterized Macros

-ifdef(show).
  -define(SHOW_EVAL(Expression), Result = Expression, io:format("~p = ~p~n",[??Expression,Result]), Result).
-else.
  -define(SHOW_EVAL(Expression), Expression).
-endif.

test() -> ?SHOW_EVAL(length([1,2,3,4,5])).
