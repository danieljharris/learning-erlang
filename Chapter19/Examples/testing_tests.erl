-module(testing_tests).

% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").

-import(testing, [treeToList/1, listToTree/1]).

tree0() ->
  {leaf, ant}.
tree1() ->
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


tree_test_() ->
  [ ?_assertEqual( tree0() , listToTree( treeToList( tree0() ) ) ),
  ?_assertEqual( tree1() , listToTree( treeToList( tree1() ) ) ) ].

leaf_test() ->
  ?assertEqual( tree0() , listToTree( treeToList( tree0() ) ) ).
node_test() ->
  ?assertEqual( tree1() , listToTree( treeToList( tree1() ) ) ).



leaf_value_test() ->
  ?assertEqual( [2,ant] , treeToList(tree0()) ).
node_value_test() ->
  ?assertEqual( [11,8,2,cat,5,2,dog,2,emu,2,fish] , treeToList(tree1()) ).

leaf_negative_test() ->
  ?assertError( badarg, listToTree([1,ant]) ).
node_negative_test() ->
  ?assertError( badarg, listToTree([8,6,2,cat,2,dog,emu,fish]) ).
