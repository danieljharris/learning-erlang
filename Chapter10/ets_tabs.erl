-module(ets_tabs).
-export([test/0, no_country/2, people/1]).
-record(person, {name, age, phone}).

-vsn(1.0).


test() -> 
	Tab = ets:new(myTab, [set, public]),
	ets:insert(Tab, {dan, cardiff}),
	ets:insert(Tab, {man, london}),
	ets:insert(Tab, {bob, scotland}),
	ets:insert(Tab, {sam, london}),
	Tab.


no_country(Table, Country) ->
	% Ms = ets:fun2ms(fun({Name, Location}) when Location /= london -> [Location, Name] end).
	ets:select(Table, [{ {'$1','$2'},[{'/=','$2', Country}],[['$2','$1']] }]).


people(FindName) ->
	ets:new(peps, [named_table, {keypos, #person.name}]),
	ets:insert(peps, #person{name="Dan",age=20,phone=159}),
	ets:insert(peps, #person{name="Man",age=21,phone=260}),
	ets:insert(peps, #person{name="Bob",age=22,phone=371}),
	ets:insert(peps, #person{name="Sam",age=23,phone=482}),
	Data = ets:lookup(peps, FindName),
	ets:delete(peps),
	Data.


% index(File) ->
% 	ets:new(indexTable, [ordered_set, named_table]),
% 	processFile(File),
% 	prettyIndex().


% processFile(File) ->
% 	{ok,IoDevice} = file:open(File,[read]),
% 	processLines(IoDevice,1).

% processLines(IoDevice,N) ->
% 	case io:get_line(IoDevice,"") of
% 		eof -> ok;
% 		Line ->
% 			processLine(Line,N),
% 			processLines(IoDevice,N+1)
% 	end.


% -define(Punctuation,"(\\ |\\,|\\.|\\;|\\:|\\t|\\n|\\(|\\))+").

% processLine(Line,N) ->
% 	case regexp:split(Line,?Punctuation) of
% 	{ok,Words} ->
% 		processWords(Words,N) ;
% 	_ -> []
% 	end.


% processWords(Words,N) ->
% 	case Words of
% 		[] -> ok;
% 		[Word|Rest] ->
% 			if
% 				length(Word) > 3 ->
% 					Normalise = string:to_lower(Word),
% 					ets:insert(indexTable, {{Normalise , N}} );
% 				true -> ok
% 			end,
% 			processWords(Rest,N)
% 	end.



% prettyIndex() ->
% 	case ets:first(indexTable) of
% 		'$end_of_table' -> ok;
% 		First ->
% 			case First of
% 				{Word, N} ->
% 					IndexEntry = {Word, [N]}
% 			end,
% 		prettyIndexNext(First,IndexEntry)
% 	end.



% prettyIndexNext(TabId,Entry,{Word, Lines}=IndexEntry) ->
% 	Next = ets:next(indexTable,Entry),
% 	case Next of
% 		'$end_of_table' -> prettyEntry(IndexEntry);
% 		{NextWord, M} ->
% 			if
% 				NextWord == Word ->
% 					prettyIndexNext(Next,{Word, [M|Lines]});
% 				true ->
% 					prettyEntry(IndexEntry),
% 					prettyIndexNext(Next,{NextWord, [M]})
% 			end
% 	end.













