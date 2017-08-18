-module(call_count).
-export([test/0]).

-define(COUNT(N), N+1)

-define(SHOW_EVAL(Expression), io:format("~p = ~p~n",[??Expression,Expression])).

test() -> ?SHOW_EVAL(length([1,2,3,4,5])).




% Exercise 7-7: Counting Calls
% How can you use the Erlang macro facility to count the number of calls to a particular function in a particular module?

% No idea how to go about doing this? Does it want me to give it a file name of a file with erlang code
% in it and then search the file for every call to a module? Or does it want me to make something that
% checks how many times a module is called from the current module?
