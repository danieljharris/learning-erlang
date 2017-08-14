-module(listSort).
-export([quicksort/1]).
-export([mergesort/1]).
-export([mergesort_split_bottom/3]).
-export([mergesort_split_top/2]).
% -export([sort/1]).
% -export([merge/2]).



quicksort([]) -> [];
quicksort([Pivot|Tail]) -> quicksort(quick_less(Tail, Pivot)) ++ [Pivot] ++ quicksort(quick_more(Tail, Pivot)).

%%Example of a one line solution I found online
%quicksort([Pivot|Tail]) -> quicksort([X || X <- Tail, X < Pivot]) ++ [Pivot] ++ quicksort([X || X <- Tail, X >= Pivot]).



quick_less(List, Max) -> quick_less_output(List, Max, []).

quick_less_output([], _, Output) -> Output;
quick_less_output([Head|Tail], Max, Output) ->
	case Head < Max of
		true -> quick_less_output(Tail, Max, Output ++ [Head]);
		false -> quick_less_output(Tail, Max, Output)
	end.


quick_more(List, Min) -> quick_more_output(List, Min, []).

quick_more_output([], _, Output) -> Output;
quick_more_output([Head|Tail], Min, Output) ->
	case Head > Min of
		true -> quick_more_output(Tail, Min, Output ++ [Head]);
		false -> quick_more_output(Tail, Min, Output)
	end.









mergesort([List]) -> List;
mergesort(List) ->
	merge(
		mergesort(mergesort_split_bottom(List, length(List) div 2, 0)),
		mergesort(mergesort_split_top(List, length(List) div 2))
	).

merge(L1, []) -> L1;
merge([], L2) -> L2;
merge([H1|T1], [H2|T2]) when H1 =< H2 -> L = [H1 | merge(T1, [H2|T2])];
merge([H1|T1], [H2|T2]) when H1 > H2 -> L = [H2 | merge([H1|T1], T2)].

mergesort_split_bottom(List, _, _) when length(List) == 1 -> [];
mergesort_split_bottom([Head|Tail], Element, Searched) when Searched < Element -> [Head] ++ mergesort_split_bottom(Tail, Element, Searched + 1);
mergesort_split_bottom(_, _, _) -> [].

mergesort_split_top(List, _) when length(List) == 1 -> List;
mergesort_split_top(List, Element) -> List -- mergesort_split_bottom(List, Element, 0).


 



% sort(L) when length(L) =< 1 -> L;
% sort(L) ->
%  merge(
%   sort(mergesort_split_bottom(L, length(L) div 2, 0)),
%   sort(mergesort_split_top(L, length(L) div 2))
%  ).
  
% merge(L1, [])  -> L1;
% merge([], L2)  -> L2;
% merge([H1|T1], [H2|T2]) when H1 =< H2 -> L = [H1 | merge(T1, [H2|T2])];
% merge([H1|T1], [H2|T2]) when H1 > H2 -> L = [H2 | merge([H1|T1], T2)].



