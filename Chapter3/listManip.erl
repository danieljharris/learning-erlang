-module(listManip).
-export([filter/2]).
-export([reverse/1]).
-export([concatenate/1]).
-export([flatten/1]).

filter(List, Max) -> filter_output(List, Max, []).

filter_output([],_,[]) -> {error, no_valid_numbers_found};
filter_output([],_,Output) -> Output;
filter_output([Head|Tail], Max, Output) when (Max >= Head) -> filter_output(Tail, Max, Output ++ [Head]);
filter_output([_|Tail], Max, Output) -> filter_output(Tail, Max, Output).


	% case (Max >= Head) of
	% 	true -> filter_output(Tail, Max, Output ++ [Head]);
	% 	false -> filter_output(Tail, Max, Output)
	% end.
reverse(List) -> reverse(List, []).

reverse([], Output) -> Output;
reverse([Head|Tail], Output) -> reverse(Tail, [Head|Output]).

% reverse([Head|Tail]) -> reverse(Tail) ++ [Head].

concatenate(List) -> concatenate(List, []).
concatenate([], Output) -> Output;
concatenate([Head|Tail], Output) -> concatenate(Tail, Output ++ Head).



% flatten(List) 						-> flatten_output(List,[]).

% flatten_output([], []) 				-> {error, list_empty};
% flatten_output([], Output) 			-> Output;
% flatten_output([Head|Tail], Output) -> flatten_output(Tail,flatten_output(Head,Output));
% flatten_output(Other, Output) 		-> Output ++ [Other].



flatten(List) 						-> flatten_output(List,[]).

flatten_output([], []) 				-> {error, list_empty};
flatten_output([], Output) 			-> Output;
flatten_output([Head|Tail], Output) -> flatten_output(Tail,flatten_output(Head,Output));
flatten_output(Other, Output) 		-> Output ++ [Other].