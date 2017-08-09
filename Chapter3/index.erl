-module(index).
-export([makeDoc/1]).
-export([makeRaw/1]).
-import(lists,[flatten/1]).
-import(io_lib,[format/1]).

makeDoc([]) -> [];
makeDoc([Head|Tail]) -> makeDoc([Head|Tail], []).
makeDoc([], Output) -> Output;
makeDoc([Head|Tail], Output) -> makeDoc(Tail, Output ++ [line_to_words(Head, [], [])]).

line_to_words([], Word, Output) -> Output ++ [Word];
line_to_words([Head|Tail], Word, Output) ->
	case [Head] of
		[$\s]  -> line_to_words(Tail, [], Output ++ [Word]);
		_Other -> line_to_words(Tail, Word ++ [Head], Output)
	end.



makeRaw([]) -> [];
makeRaw([Head|Tail]) -> makeRaw([Head|Tail], []).
makeRaw([], Output) -> Output;
makeRaw([Head|Tail], Output) -> makeRaw(Tail, Output ++ [words_to_line(Head)]).

words_to_line([]) -> [];
words_to_line([Head|Tail]) -> Head ++ "\s" ++ words_to_line(Tail).

count_occurrences(_, []) -> [];
count_occurrences(Element, List) -> count_occurrences(Element, List, 0).
count_occurrences(_, [], AmountFound) -> AmountFound;
count_occurrences(Element, [Head|Tail], AmountFound) when Element == Head -> count_occurrences(Element, Tail, AmountFound + 1);
count_occurrences(Element, [_|Tail], AmountFound) -> count_occurrences(Element, Tail, AmountFound).

index(_, []) -> [];
index(Element, List) -> {Element, index(Element, List, 1, [])}.
index(_, [], _, Output) -> Output;
index(Element, [Head|Tail], Page, Output) ->
	case count_occurrences(Element, Head) > 0 of
		true  -> index(Element, Tail, Page + 1, Output ++ [Page]);
		false -> index(Element, Tail, Page + 1, Output)
	end.

readable({Head,Tail}) -> Head ++ "\s" ++ compress(Tail).

compress([]) -> [];
compress(List) -> compress(List, []).
compress([], Output) -> Output;
compress(List, Output) when length(List) == 1 -> Output ++ List;	
compress([Head|Tail], _) when (Tail - Head) =< 1 -> [];
compress([Head|Tail], Output) when (Tail - Head) >= 1 -> Output ++ [Head];
compress([Head,Next|Tail], Output) ->
	if
		(Next - Head) == 0 -> compress([Head|Tail], Output);
		(Next - Head) == 1 -> compress([Next|Tail], Output ++ [Head] ++ ["+"] );
		(Next - Head) >= 1 -> compress([Next|Tail], Output ++ [Head])
	end.

%%Use shell:string(false).
%char_to_integer(Char) -> lists:flatten(io_lib:format("~p", [Char])).