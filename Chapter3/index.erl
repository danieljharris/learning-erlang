-module(index).
-export([makeDoc/1]).
-export([makeRaw/1]).
-import(lists,[flatten/1]).
-import(io_lib,[format/1]).
-import(lists,[nth/2]).

%Turns a 'raw document' into a 'document'
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


%Turns a 'document' into a 'raw document'
makeRaw([]) -> [];
makeRaw([Head|Tail]) -> makeRaw([Head|Tail], []).
makeRaw([], Output) -> Output;
makeRaw([Head|Tail], Output) -> makeRaw(Tail, Output ++ [words_to_line(Head)]).

words_to_line([]) -> [];
words_to_line([Head|Tail]) -> Head ++ "\s" ++ words_to_line(Tail).

%Finds all occurances of a string in a 'document'
count_occurrences(_, []) -> [];
count_occurrences(Element, List) -> count_occurrences(Element, List, 0).
count_occurrences(_, [], AmountFound) -> AmountFound;
count_occurrences(Element, [Head|Tail], AmountFound) when Element == Head -> count_occurrences(Element, Tail, AmountFound + 1);
count_occurrences(Element, [_|Tail], AmountFound) -> count_occurrences(Element, Tail, AmountFound).

%Finds the pages that the element is on from a 'document'
index(_, []) -> [];
index(Element, List) -> {Element, index(Element, List, 1, [])}.
index(_, [], _, Output) -> Output;
index(Element, [Head|Tail], Page, Output) ->
	case count_occurrences(Element, Head) > 0 of
		true  -> index(Element, Tail, Page + 1, Output ++ [Page]);
		false -> index(Element, Tail, Page + 1, Output)
	end.

readable({Head,Tail}) -> Head ++ " " ++ compress_pretty(compress_link(compress(Tail))).

%%Compresser (Removes duplicates) [1,1,1,2,2,5,7,9,9] -> [1,2,5,7,9]
compress([]) -> [];
compress(List) -> compress(List, []).

compress([], Output) -> Output;
compress(List, Output) when length(List) == 1 -> Output ++ List;	
compress([Head|Tail], _) when (Tail - Head) =< 1 -> [];
compress([Head|Tail], Output) when (Tail - Head) >= 1 -> Output ++ [Head];
compress([Head,Next|Tail], Output) ->
	if
		(Next - Head) == 0 -> compress([Head|Tail], Output);
		% (Next - Head) == 1 -> compress([Next|Tail], Output ++ [Head] ++ ["-"] );
		(Next - Head) >= 1 -> compress([Next|Tail], Output ++ [Head])
	end.


%%Linker (Links adjacent numbers) [1,2,5,8,9,10] -> [{1,2},{5},{8,10}]
compress_link([]) -> [];
compress_link(List) -> compress_link(List, {0, 0}, []).

compress_link([], _, Output) -> Output;
compress_link([Head,Next], Range, Output) -> 
	if
		(Next - Head == 1) and (Range == {0, 0}) -> Output ++ [{Head, Next}];
		(Next - Head == 1) -> Output ++ [{element(1, Range), Next}];
		(Next - Head >= 1) and (Range /= {0, 0}) -> Output ++ [{element(1, Range),Head},{Next}];
		(Next - Head >= 1) -> Output ++ [{Head},{Next}]
	end;
compress_link([Head,Next|Tail], Range, Output) ->
	if
		(Next - Head == 1) and (Range == {0, 0}) -> compress_link([Next|Tail], {Head, 0}, Output);
		(Next - Head == 1) -> compress_link([Next|Tail], {element(1, Range), Next}, Output);
		(Next - Head >= 1) and (Range == {0, 0}) -> compress_link([Next|Tail], {0, 0}, Output ++ [{Head}]);
		(Next - Head >= 1) -> compress_link([Next|Tail], {0, 0}, Output ++ [{element(1, Range),Head}])
	end.

%Prettyer (List with tuples to string) [{1,2},{3},{5,9}] -> "1-2,3,5-9,"
compress_pretty([]) -> [];
compress_pretty([Head|Tail]) when tuple_size(Head) == 1 -> char_to_integer(element(1,Head)) ++ "," ++ compress_pretty(Tail);
compress_pretty([Head|Tail]) when tuple_size(Head) == 2 ->
	char_to_integer(  element(1,Head)) ++ "-" ++ char_to_integer(element(2,Head)  )
	++ "," ++ compress_pretty(Tail).






%compress_link(Item, _, Output) -> Output ++ [{Item}].


% compress_to_list(Num,[],_) -> Num;
% compress_to_list(Num, List) when lists:nth(length(List) - 2, List) == "-" -> compress_to_list(Num, List);
% compress_to_list(Num, List) when lists:nth(length(List), List) .

%%Use shell:string(false).
char_to_integer(Char) -> lists:flatten(io_lib:format("~p", [Char])).










