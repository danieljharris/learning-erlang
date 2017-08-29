-module(trees).
-export([example_tree/0, treeToList/1, listToTree/1, deserialize/1, list_serialization/1, binary_deserialization/1]).

-vsn(1.0).

example_tree() ->
  {node,
    {node,
      {leaf,cat},
      {node,
        {leaf,dog},
        {leaf,emu}
      }
    },
    {leaf,fish}
  }.

treeToList({leaf,N}) ->
  [2,N];
treeToList({node,T1,T2}) ->
  TTL1 = treeToList(T1), [Size1|_] = TTL1,
  TTL2 = treeToList(T2), [Size2|List2] = TTL2,
  [Size1+Size2|TTL1++List2].



deserialize([_|Ls]) -> listToTree(Ls).

listToTree([2,N]) -> {leaf,N};
listToTree([N]) -> {leaf,N};
listToTree([M|Rest] = _Code) -> 
  {Code1,Code2} = lists:split(M-1,Rest),
  {node, listToTree(Code1), listToTree(Code2)}.



% Exercise 9-6: Bitstrings
list_serialization(List) -> list_serialization(List, << >>).

list_serialization([], Acc) -> Acc;

list_serialization([Head|Tail], Acc) when is_atom(Head) ->
  BinaryHead = erlang:atom_to_binary(Head, latin1),
  list_serialization(Tail, << Acc/binary, 0, BinaryHead/binary, 0>>);

list_serialization([Head|Tail], Acc) -> 
  list_serialization(Tail, << Acc/binary, Head >>).



binary_deserialization(Binary) ->
  binary_deserialization(Binary, []).

binary_deserialization(<<0, Tail/binary>>, Acc) ->
  {NewBinary, Atom} = extract_atom(Tail, []),
  binary_deserialization(NewBinary, [Atom | Acc]);

binary_deserialization(<<Head:1/binary, Tail/binary>>, Acc) ->
  [ListValue] = io_lib:format("~w", erlang:binary_to_list(Head)),
  {IntValue, _} = string:to_integer(ListValue),
  binary_deserialization(<<Tail/binary>>, [IntValue | Acc] );

binary_deserialization(_, Acc) -> lists:reverse(Acc).


extract_atom(<<0, Tail/binary>>, Acc) ->
  {Tail, erlang:list_to_atom(lists:reverse(lists:concat(Acc)))};
extract_atom(<<Head:1/binary, Tail/binary>>, Acc) ->
  extract_atom(Tail, [erlang:binary_to_atom(Head, latin1) | Acc]).
