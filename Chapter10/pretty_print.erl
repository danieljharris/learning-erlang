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
  case io:get_line(IoDevice, "") of
    eof -> ok;
    Line ->
      processLine(Line, N),
      processLines(IoDevice, N+1)
  end.


-define(Punctuation, "[\\ |\\,|\\.|\\;|\\:|\\t|\\n|\\(|\\)]").

processLine(Line,N) ->
  Words = re:split(Line, ?Punctuation, [{return,list}]),
  processWords(Words, N).

processWords([], _N) -> ok;
processWords([Word|Rest], N) when length(Word) > 3 ->
  Normalise = string:to_lower(Word),
  case ets:lookup(indexTable, Normalise) of
    [] -> 
      ets:insert(indexTable, {Normalise , [N]} );
    [{Normalise, Lines}] ->
      ets:delete(indexTable, Normalise),
      ets:insert(indexTable, {Normalise , Lines ++ [N]})
  end,
  processWords(Rest,N);
processWords([_Word|Rest], N) -> processWords(Rest,N).


prettyIndex() ->
  case ets:first(indexTable) of
    [] -> ok;
    FirstKey ->
      [{Word, Lines}] = ets:lookup(indexTable, FirstKey),
      IndexEntry = {Word, Lines},
      prettyIndexNext(FirstKey, IndexEntry)
  end.

prettyIndexNext(EntryKey, IndexEntry) ->
  Next = ets:next(indexTable,EntryKey),
  case ets:lookup(indexTable, Next) of
    [] -> ok;
    [{NextWord, Occurrences}] ->
        prettyEntry(IndexEntry),
        prettyIndexNext(Next, {NextWord, Occurrences})
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
  compress_link(List).


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
compress_link(List) -> lists:reverse(compress_link(List, {0, 0}, [])).

compress_link([], _Range, Output) -> Output;

compress_link([Head,Next], {0, 0}, Output)
  when (Next - Head == 1) -> [{Head, Next} | Output];
compress_link([Head,Next], {R1, _R2}, Output)
  when (Next - Head == 1) -> [{R1, Next} | Output];
compress_link([Head,Next], {R1, _R2} = Range, Output)
  when (Next - Head >= 1) and (Range /= {0, 0}) ->
    [{R1,Head},{Next} | Output];
compress_link([Head,Next], _Range, Output)
  when (Next - Head >= 1) -> [{Next}, {Head} | Output];


compress_link([Head,Next|Tail], {0, 0}, Output)
  when (Next - Head == 1) -> compress_link([Next|Tail], {Head, 0}, Output);
compress_link([Head,Next|Tail], {R1, _R2}, Output)
  when (Next - Head == 1) -> compress_link([Next|Tail], {R1, Next}, Output);
compress_link([Head,Next|Tail], {0,0}, Output)
  when (Next - Head >= 1) -> compress_link([Next|Tail], {0, 0}, [{Head} | Output]);
compress_link([Head,Next|Tail], {R1, _R2}, Output)
  when (Next - Head >= 1) -> compress_link([Next|Tail], {0, 0}, [{R1,Head} | Output]).


%Prettyer (List with tuples to string) [{1,2},{3},{5,9}] -> "1-2,3,5-9"
compress_pretty([]) -> [];

compress_pretty([ {Element} |Tail]) ->
  case compress_pretty(Tail) of
    [] ->
      char_to_integer( Element );
    Compressed_Tail ->
      char_to_integer( Element ) ++ ", " ++ Compressed_Tail
  end;

compress_pretty([ {Element1, Element2} |Tail]) ->
  case compress_pretty(Tail) of
    [] ->
      char_to_integer( Element1 ) ++ "-" ++ char_to_integer( Element2 );
    Compressed_Tail ->
        char_to_integer( Element1 ) ++ "-" ++ char_to_integer( Element2 )
        ++ "," ++ Compressed_Tail
    end.

char_to_integer(Char) -> lists:flatten(io_lib:format("~p", [Char])).
