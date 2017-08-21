-module(ziper).
-export([zip/2, zipWith/2]).

-vsn(1.0).

% Exercise 9-3: Zip Functions


% "Define the function zip, which turns a pair of lists into a list of pairs:"

% They didnt say I needed to use list comprehension and I couldent
% think of a way of using it in this case, so I just did it without it
zip([],_) -> [];
zip(_,[]) -> [];
zip([H1|T1],[H2|T2]) -> [{H1,H2} | zip(T1, T2) ].




% "Using this example, define the function zipWith that applies a
% binary function to two lists of arguments, in lock step:"

% Not sure what the question is asking for, but I made this function
% that works as shown
zipWith([],_) -> [];
zipWith(_,[]) -> [];
zipWith([H1|T1],[H2|T2]) -> [H1 + H2 | zipWith(T1, T2) ].