-module(serial).
-export([ex_tree/0, serialize/1, deserialize/1]).

-vsn(1.0).

% Exercise 9-6: Bitstrings

% Using bitstring constructors and pattern matching,
% give a bit-level implementation of the serialization
% algorithm in the section “Serialization” on page 208.

% You will need to think about how much storage is needed
% for the various items, including the size information
% that forms part of the sequence.


ex_tree() ->
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


serialize(Tree) -> treeToList(Tree).

treeToList({leaf,N}) ->
	[2,N];
treeToList({node,T1,T2}) ->
	TTL1 = treeToList(T1), [Size1|_] = TTL1,
	TTL2 = treeToList(T2), [Size2|List2] = TTL2,
	[Size1+Size2|TTL1++List2].



deserialize([_|Ls]) -> listToTree(Ls).

listToTree([2,N]) -> {leaf,N};
listToTree([N]) -> {leaf,N};
listToTree([M|Rest] = Code) -> 
	{Code1,Code2} = lists:split(M-1,Rest),
	{node, listToTree(Code1), listToTree(Code2)}.



