-module(para_macros).
-export([test/0]).

-ifdef(show).
	-define(SHOW_EVAL(Expression), io:format("~p = ~p~n",[??Expression,Expression])).
-else.
	-define(SHOW_EVAL(Expression), io:format("~p = ~p~n",[Expression])).
-endif.

-define(VALUE(Call),io:format("~p = ~p~n",[??Call,Call])).

times(A,B) ->
	?DBG("in records1:birthday(~p)~n", [P]),
	P#person{age=Age+1}.


