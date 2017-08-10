-module(textPro).
-export([filled/1]).
-export([justify/1]).

%Turns long lines in a 'document' into filled lines with a max of 40 characters per line
filled([]) -> [];
filled([Head|Tail]) -> [filled(Head, [], [])] ++ filled(Tail);
filled(List) -> filled(List, [], []).

filled([], Line, Output) -> Output ++ [Line];
filled([Head|Tail], Line, Output) ->
	case size_of_contents(Line) =< (40 - length(Head)) of
		true  -> filled(Tail, Line ++ [Head], Output);
		false -> filled(Tail, [Head], Output ++ [Line])
	end.

%Finds the length of the contents of a list and spaces between them, ["Hello","Erlang","World"] -> 19
size_of_contents([]) -> 0;
size_of_contents(List) -> size_of_contents(List, 0).
size_of_contents([Head|Tail], Output) -> size_of_contents(Tail, (Output + length(Head) + 1));
size_of_contents(List, Output) -> Output + length(List).


%Fills out lines so if there is a line with 38 characters it adds two spaces
justify([]) -> [];
justify([Head|Tail]) ->
	case size_of_contents(Head) =< 40 of
		true  -> [add_spaces(Head, 40 - size_of_contents(Head) )] ++ justify(Tail);
		false -> [Head] ++ justify(Tail)
	end;
justify(List) ->
	case size_of_contents(List) =< 40 of
		true  -> [add_spaces(List, 40 - size_of_contents(List) )];
		false -> [List]
	end.

%Adds a set amout of spaces between strings in a list
add_spaces([], _) -> [];
add_spaces(List, Spaces)   when Spaces == 0 -> List;
add_spaces([Head|Tail], Spaces) when Spaces >= 0 -> [Head] ++ ["\s"] ++ add_spaces(Tail, Spaces - 1).