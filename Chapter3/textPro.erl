-module(textPro).
-export([filled/1]).

filled([]) -> [];
filled([Head|Tail]) -> filled(Head, [], []).

filled([], Line, Output) -> Output ++ Line;
filled([Head|Tail], Line, Output) when length(Line) =< (40 - [Head]) -> filled(Tail, Line ++ [Head], Output);
filled([Head|Tail], Line, Output) when length(Line) >  (40 - [Head]) -> filled(Tail, [Head], Output ++ Line).