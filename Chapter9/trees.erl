-module(trees).
-export([example_tree/0, treeToList/1, listToTree/1, deserialize/1, list_serialization/1, binary_deserialization/1]).

-vsn(1.0).

example_tree() ->
  {node,
    {node,
      {leaf,car},
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
list_serialization(List) -> erlang:term_to_binary(List).
binary_deserialization(Binary) -> erlang:binary_to_term(Binary).
