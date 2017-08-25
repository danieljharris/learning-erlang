-module(debug_tree).
-export([sum/1, max/1, is_ordered/1, add_in_order/2]).

-record(tree, {val, lnode, rnode}).


-ifdef(debug).
	-define(DEBUG(Message), io:format("~p~n",[Message])).
-else.
	-define(DEBUG(Message), ok).
-endif.





% Exercise 7-9: Debugging the db.erl Exercise


sum(#tree{val=Val, lnode=undefined, rnode=undefined})	->
	?DEBUG("Sum: End node reached"), 							Val;


sum(#tree{val=Val, lnode=Lnode, rnode=undefined})		->
	?DEBUG("Sum: Right node missing, looking at left node"), 	Val + sum(Lnode);


sum(#tree{val=Val, lnode=undefined, rnode=Rnode})		->
	?DEBUG("Sum: Left node missing, looking at right node"), 	Val + sum(Rnode);


sum(#tree{val=Val, lnode=Lnode, rnode=Rnode})			->
	?DEBUG("Sum: Looking at both nodes"), 						Val + sum(Lnode) + sum(Rnode).



max(#tree{val=Val, lnode=undefined, rnode=undefined}) -> ?DEBUG("Max: End node reached"), Val;

max(#tree{val=Val, lnode=Lnode, rnode=undefined}) -> 
	?DEBUG("Max: Right node missing, looking at left node"), 
	case Val >= (L=max(Lnode)) of
		true  -> Val;
		false -> L
	end;

max(#tree{val=Val, lnode=undefined, rnode=Rnode}) ->
	?DEBUG("Max: Left node missing, looking at right node"), 
	case Val >= (R=max(Rnode)) of
		true  -> Val;
		false -> R
	end;

max(#tree{val=Val, lnode=Lnode, rnode=Rnode}) ->
	?DEBUG("Max: Looking at both nodes"), 
	L=max(Lnode),
	R=max(Rnode),
	if
		(Val >= L) and (Val >= R) -> Val;
		L >= R -> L;
		true -> R
	end.



is_ordered(#tree{val=Val, lnode=undefined, rnode=undefined}) -> ?DEBUG("Is Ordered: End node reached"), Val;

is_ordered(#tree{val=Val, lnode=Lnode, rnode=undefined}) -> 
	?DEBUG("Is Ordered: Right node missing, looking at left node"), 
	case is_ordered(Lnode) of
		false -> false;
		Other ->
			if
				Val >= Other -> Val;
				true -> false
			end
	end;

is_ordered(#tree{val=Val, lnode=undefined, rnode=Rnode}) ->
	?DEBUG("Is Ordered: Left node missing, looking at right node"), 
	case is_ordered(Rnode) of
		false -> false;
		Other ->
			if
				Val =< Other -> Val;
				true -> false
			end
	end;

is_ordered(#tree{val=Val, lnode=Lnode, rnode=Rnode}) ->
	?DEBUG("Is Ordered: Looking at both nodes"), 
	L=is_ordered(Lnode),
	R=is_ordered(Rnode),
	if
		not L or not R -> false;
		(Val >= L) and (Val =< R) -> Val;
		true -> false
	end.



add_in_order(	#tree{val=undefined}, Add) ->
	?DEBUG("Add In Order: End node reached"), 
				#tree{val=Add};


add_in_order(	#tree{val=Val, lnode=Lnode,						rnode=undefined		}, Add) when Add >= Val ->
	?DEBUG("Add In Order: Right node missing, looking at left node"),
				#tree{val=Val, lnode=Lnode,						rnode=#tree{val=Add}};


add_in_order(	#tree{val=Val, lnode=undefined,					rnode=Rnode			}, Add) when Add <  Val ->
	?DEBUG("Add In Order: Left node missing, looking at right node"),
				#tree{val=Val, lnode=#tree{val=Add},			rnode=Rnode			};


add_in_order(	#tree{val=Val, lnode=Lnode,						rnode=Rnode			}, Add) when Add <  Val ->
	?DEBUG("Add In Order: Adding to the left node"),
				#tree{val=Val, lnode=add_in_order(Lnode, Add),	rnode=Rnode			};


add_in_order(	#tree{val=Val, lnode=Lnode,						rnode=Rnode			}, Add) when Add >= Val ->
	?DEBUG("Add In Order: Adding to the right node"),
				#tree{val=Val, lnode=Lnode,						rnode=add_in_order(Rnode, Add)	}.














