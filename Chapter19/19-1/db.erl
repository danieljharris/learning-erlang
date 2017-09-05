-module(db).
-export([new/0]).
-export([destroy/1]).
-export([write/3]).
-export([delete/2]).
-export([read/2]).
-export([match/2]).

new() -> [].
destroy(_) -> ok	.
write(Key, Element, Db) -> Db ++ [{Key, Element}].

delete(Key, Db) ->
  case read(Key, Db) of
    {error, key_not_found} ->
      {error, key_not_found};
    {_, Element} ->
      Db -- [{Key, Element}]
  end.

read(_, []) -> {error, key_not_found};
read(Key, [{Key, Element}|_]) -> {ok, Element};
read(Key, [_|Tail]) -> read(Key, Tail).

match(_, []) -> {error, element_not_found};
match(Element, List) -> list_match(Element, List, []).

list_match(_, [], []) -> {error, element_not_found};
list_match(_, [], Output) -> Output;
list_match(Element, [{Key, Element}|Tail], Output) -> list_match(Element, Tail, Output ++ [{Key, Element}] );
list_match(Element, [_|Tail], Output) -> list_match(Element, Tail, Output).
