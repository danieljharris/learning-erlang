-module(listManip).
-export([filter/2]).
-export([reverse/1]).
-export([concatenate/1]).
-export([flatten/1]).

filter(List, Max) -> filter_output(List, Max, []).

filter_output([],_,[]) -> {error, no_valid_numbers_found};
filter_output([],_,Output) -> Output;
filter_output([Head|Tail], Max, Output) ->
	case (Max >= Head) of
		true -> filter_output(Tail, Max, Output ++ [Head]);
		false -> filter_output(Tail, Max, Output)
	end.

reverse([]) -> [];
reverse([Head|Tail]) -> reverse(Tail) ++ [Head].

concatenate([]) -> [];
concatenate([Head|Tail]) -> Head ++ concatenate(Tail).

flatten(List) -> flatten_output(List,[]).
flatten_output([],[]) -> {error, no_numbers};
flatten_output([],Output) -> Output;
flatten_output([Head|Tail],Output) -> flatten_output(Tail,flatten_output(Head,Output));
flatten_output(Other,Output) -> Output++[Other].
