-module(pretty_print).
-export([index/0, index/1, accumulate/1, prettyList/1, pad/2]).
-include("usr.hrl").

-vsn(1.0).


get_path() -> "/Users/daniel.harris/Documents/ErlTestFunctions/Chapter10/indexme.txt".

index() -> index(get_path()).


% Exercise 10-2: Indexing Revisited
index(File) ->
	ets:new(indexTable, [ordered_set, named_table, {keypos, 1}]),
	processFile(File),
	prettyIndex(),
	ets:delete(indexTable).


processFile(File) ->
	{ok,IoDevice} = file:open(File,[read]),
	processLines(IoDevice,1).

processLines(IoDevice,N) ->
	case io:get_line(IoDevice,"") of
		eof -> ok;
		Line ->
			processLine(Line,N),
			processLines(IoDevice,N+1)
	end.


-define(Punctuation, "[\\ |\\,|\\.|\\;|\\:|\\t|\\n|\\(|\\)]").

processLine(Line,N) ->
	Words = re:split(Line, ?Punctuation, [{return,list}]),
	processWords(Words, N).


processWords(Words,N) ->
	case Words of
		[] -> ok;
		[Word|Rest] ->
			if
				length(Word) > 3 ->
					Normalise = string:to_lower(Word),
					ets:insert(indexTable, {{Normalise , N}} );
				true -> ok
			end,
			processWords(Rest,N)
	end.



prettyIndex() ->
	case ets:first(indexTable) of
		'$end_of_table' -> ok;
		First ->
			case First of
				{Word, N} ->
					IndexEntry = {Word, [N]}
			end,
		prettyIndexNext(First, IndexEntry)
	end.



prettyIndexNext(Entry, {Word, Lines}=IndexEntry) ->
	Next = ets:next(indexTable,Entry),
	case Next of
		'$end_of_table' -> prettyEntry(IndexEntry);
		{NextWord, M} ->
			if
				NextWord == Word ->
					prettyIndexNext(Next, {Word, [M|Lines]});
				true ->
					prettyEntry(IndexEntry),
					prettyIndexNext(Next, {NextWord, [M]})
			end
	end.





% Exercise 10-1: Pretty-Printing
prettyEntry({Word, Lines}) when length(Lines) == 1 ->
	Paded = pad(20, Word),
	[Entry] = Lines,

	Output = Paded ++ char_to_integer(Entry),

	io:format("~p~n",[Output]);

prettyEntry({Word, Lines}) ->
	Acc = accumulate(Lines),
	PList = prettyList(Acc),

	Paded = pad(20, Word),

	Output = Paded ++ PList,

	io:format("~p~n",[Output]).



% This function should take a list of line numbers,
% in descending order, and produce a list containing
% ranges as well as removing duplicates.
accumulate(List) ->
	Sorted = lists:sort(List),
	compress_link(Sorted).


% This function will print the output of accumulate so
% that on the list [{1},{3}, {5,7}] the output is 1,3,5-7
prettyList(List) ->
	compress_pretty(List).


% This function, called with number N and string Word,
% will return the string padded to the right with spaces
% to give it length N (assuming Word is not longer than N).
pad(N, Word) when length(Word) < N -> pad(N, Word ++ [$\s]);
pad(_, Word) -> Word.



%%Linker (Links adjacent numbers) [1,2,5,8,9,10] -> [{1,2},{5},{8,10}]
compress_link([]) -> [];
compress_link(List) -> compress_link(List, {0, 0}, []).

compress_link([], _Range, Output) -> Output;

compress_link([Head,Next], {0, 0}, Output)
  when (Next - Head == 1) -> Output ++ [{Head, Next}];
compress_link([Head,Next], Range, Output)
  when (Next - Head == 1) -> Output ++ [{element(1, Range), Next}];
compress_link([Head,Next], Range, Output)
  when (Next - Head >= 1) and (Range /= {0, 0}) ->
    Output ++ [{element(1, Range),Head},{Next}];
compress_link([Head,Next], _Range, Output)
  when (Next - Head >= 1) -> Output ++ [{Head},{Next}];


compress_link([Head,Next|Tail], {0, 0}, Output)
  when (Next - Head == 1) -> compress_link([Next|Tail], {Head, 0}, Output);
compress_link([Head,Next|Tail], Range, Output)
  when (Next - Head == 1) -> compress_link([Next|Tail], {element(1, Range), Next}, Output);
compress_link([Head,Next|Tail], {0,0}, Output)
  when (Next - Head >= 1) -> compress_link([Next|Tail], {0, 0}, Output ++ [{Head}]);
compress_link([Head,Next|Tail], Range, Output)
	when (Next - Head >= 1) -> compress_link([Next|Tail], {0, 0}, Output ++ [{element(1, Range),Head}]).


%Prettyer (List with tuples to string) [{1,2},{3},{5,9}] -> "1-2,3,5-9,"
compress_pretty([]) -> [];

compress_pretty([Head|Tail]) when tuple_size(Head) == 1 ->
  char_to_integer(element(1,Head)) ++ ", " ++ compress_pretty(Tail);

compress_pretty([Head|Tail]) when tuple_size(Head) == 2 ->
	char_to_integer(  element(1,Head)) ++ "-" ++ char_to_integer(element(2,Head)  )
	++ "," ++ compress_pretty(Tail).


char_to_integer(Char) -> lists:flatten(io_lib:format("~p", [Char])).
