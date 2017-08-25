-module(binary_tree).

-compile({no_auto_import,[max/2]}).

-export([sum/1, max/1, is_ordered/1, add_in_order/2]).

-record(tree, {val, lnode, rnode}).

% Exercise 7-5: Binary Tree Records

sum(#tree{val=Val, lnode=undefined, rnode=undefined})  -> Val;
sum(#tree{val=Val, lnode=Lnode,     rnode=undefined})  -> Val + sum(Lnode);
sum(#tree{val=Val, lnode=undefined, rnode=Rnode    })  -> Val + sum(Rnode);
sum(#tree{val=Val, lnode=Lnode,     rnode=Rnode    })  -> Val + sum(Lnode) + sum(Rnode).


max(#tree{val=Val, lnode=undefined, rnode=undefined}) -> Val;
max(#tree{val=Val, lnode=Lnode,     rnode=undefined}) -> max( max(Lnode), Val );
max(#tree{val=Val, lnode=undefined, rnode=Rnode    }) -> max( max(Rnode), Val );
max(#tree{val=Val, lnode=Lnode,     rnode=Rnode    }) -> max( max( max(Lnode), max(Rnode) ), Val ).

max(LH, RH) when LH > RH -> LH;
max(_LH, RH) -> RH.


is_ordered(Tree) ->
  case ordered(Tree) of
    false -> false;
    _Other -> true
  end.

ordered(#tree{val=Val, lnode=undefined, rnode=undefined}) -> Val;
ordered(#tree{val=Val, lnode=Lnode,     rnode=undefined}) -> ordered( ordered(Lnode), Val );
ordered(#tree{val=Val, lnode=undefined, rnode=Rnode    }) -> ordered( Val, ordered(Rnode) );
ordered(#tree{val=Val, lnode=Lnode,     rnode=Rnode    }) -> ordered( ordered( ordered(Lnode), Val ), ordered(Rnode) ).

ordered(false, _) -> false;
ordered(_, false) -> false;
ordered(LH, RH) when LH =< RH -> RH;
ordered(_LH, _RH) -> false.



add_in_order(#tree{val=undefined}, Add) -> #tree{val=Add};

add_in_order(#tree{val=Val, lnode=undefined, rnode=Rnode}, Add) when Add <  Val ->
  #tree{val=Val, lnode=#tree{val=Add}, rnode=Rnode};

add_in_order(#tree{val=Val, lnode=Lnode, rnode=undefined}, Add) when Add >= Val ->
  #tree{val=Val, lnode=Lnode, rnode=#tree{val=Add} };

add_in_order(#tree{val=Val, lnode=Lnode, rnode=Rnode}, Add) when Add < Val ->
  #tree{val=Val, lnode=add_in_order(Lnode, Add), rnode=Rnode};

add_in_order(#tree{val=Val, lnode=Lnode, rnode=Rnode}, Add) when Add >= Val ->
  #tree{val=Val, lnode=Lnode, rnode=add_in_order(Rnode, Add)}.
