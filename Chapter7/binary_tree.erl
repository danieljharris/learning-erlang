-module(binary_tree).
-export([sum/1, max/1, is_ordered/1, add_in_order/2]).

-record(tree, {val, lnode, rnode}).

% Exercise 7-5: Binary Tree Records

sum(#tree{val=Val, lnode=undefined, rnode=undefined}) -> Val;
sum(#tree{val=Val, lnode=Lnode, rnode=undefined})	  -> Val + sum(Lnode);
sum(#tree{val=Val, lnode=undefined, rnode=Rnode}) 	  -> Val + sum(Rnode);
sum(#tree{val=Val, lnode=Lnode, rnode=Rnode})	  	  -> Val + sum(Lnode) + sum(Rnode).



max(#tree{val=Val, lnode=undefined, rnode=undefined}) -> Val;

max(#tree{val=Val, lnode=Lnode, rnode=undefined}) -> 
	case Val >= (L=max(Lnode)) of
		true  -> Val;
		false -> L
	end;

max(#tree{val=Val, lnode=undefined, rnode=Rnode}) ->
	case Val >= (R=max(Rnode)) of
		true  -> Val;
		false -> R
	end;

max(#tree{val=Val, lnode=Lnode, rnode=Rnode}) ->
	L=max(Lnode),
	R=max(Rnode),
	if
		(Val >= L) and (Val >= R) -> Val;
		L >= R -> L;
		true -> R
	end.



is_ordered(#tree{val=Val, lnode=undefined, rnode=undefined}) -> Val;

is_ordered(#tree{val=Val, lnode=Lnode, rnode=undefined}) -> 
	case is_ordered(Lnode) of
		false -> false;
		Other ->
			if
				Val >= Other -> Val;
				true -> false
			end
	end;

is_ordered(#tree{val=Val, lnode=undefined, rnode=Rnode}) ->
	case is_ordered(Rnode) of
		false -> false;
		Other ->
			if
				Val =< Other -> Val;
				true -> false
			end
	end;

is_ordered(#tree{val=Val, lnode=Lnode, rnode=Rnode}) ->
	L=is_ordered(Lnode),
	R=is_ordered(Rnode),
	if
		not L or not R -> false;
		(Val >= L) and (Val =< R) -> Val;
		true -> false
	end.



add_in_order(#tree{val=undefined}, Add) 											-> #tree{val=Add};

add_in_order(#tree{val=Val, lnode=undefined, rnode=Rnode    }, Add) when Add <  Val -> #tree{val=Val, lnode=#tree{val=Add},           rnode=Rnode          };
add_in_order(#tree{val=Val, lnode=Lnode,     rnode=undefined}, Add) when Add >= Val -> #tree{val=Val, lnode=Lnode,                    rnode=#tree{val=Add} };

add_in_order(#tree{val=Val, lnode=Lnode,     rnode=Rnode},     Add) when Add <  Val -> #tree{val=Val, lnode=add_in_order(Lnode, Add), rnode=Rnode                    };
add_in_order(#tree{val=Val, lnode=Lnode,     rnode=Rnode},     Add) when Add >= Val -> #tree{val=Val, lnode=Lnode,                    rnode=add_in_order(Rnode, Add) }.














