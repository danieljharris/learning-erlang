-module(db).
-export([new/0]).
-export([destroy/1]).
-export([write/3]).
-export([delete/2]).
-export([read/2]).
-export([match/2]).

new() -> [].
destroy(Db) -> 0.
write(Key, Element, Db) -> Db ++ [{Key, Element}].

delete(Key, Db) -> Db -- match(Key, Db).

read(Key, []) -> {error, element_not_found};
read(Key, [Head|Tail]) ->
   case read_check(Key, Head) of
      true -> Head;
      false -> read(Key, Tail)
   end.

read_check(Key, Head) when is_tuple(Head) -> read_check(Key, tuple_to_list(Head));
read_check(Key, [Head|Tail]) -> Key == Head.


match(Element, []) -> {error, element_not_found};
match(Element, List) -> list_match(Element, List, []).

list_match(_, [], []) -> {error, element_not_found};
list_match(_, [], Output) -> Output;
list_match(Element, [Head|Tail], Output) ->
   case match_check(Element, Head) of
      true -> list_match(Element, Tail, (Output ++ [Head]));
      false -> list_match(Element, Tail, Output)
   end.

match_check(Element, List) when is_tuple(List) -> match_check(Element, tuple_to_list(List));
match_check(Element, [_|Tail]) -> [Element] == Tail.
