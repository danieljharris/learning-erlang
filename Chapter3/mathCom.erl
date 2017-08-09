-module(mathCom).
-export([parser/1]).
-export([eval/1]).
-export([pretty/1]).
-import(lists,[flatten/1]).
-import(io_lib,[format/1]).

%%The super duper number thingy!
%%Have not done: simulator? maybe, conditionals, local definitions (All this on page 109)
parser([]) -> [];
parser([Head|Tail]) ->
	case [Head] of
		"(" -> {parser_operate(Tail),parser_l(Tail),parser_r(Tail)};
		"+" -> parser(Tail);
		"-" -> parser(Tail);
		"/" -> parser(Tail);
		"*" -> parser(Tail);
		")" -> parser(Tail);
		[$~]-> parser(Tail);
		_   -> [Head]
	end.

%Runs untill it gets to a symbol and then returns that symbol's name
parser_operate([]) -> [];
parser_operate([Head|Tail]) ->
	case [Head] of
		"+" -> plus;
		"-" -> minus;
		"/" -> divide;
		"*" -> times;
		"(" -> parser_operate(parser_skip(Tail, 1));
		_   -> parser_operate(Tail)
	end.

%Gets the expression from the left
parser_l([]) -> [];
parser_l([Head|Tail]) ->
	case [Head] of
		"+" -> parser_l(Tail);
		"-" -> parser_l(Tail);
		"/" -> parser_l(Tail);
		"*" -> parser_l(Tail);
		"(" -> parser([Head] ++ Tail);
		")" -> parser_l(Tail);
		%[$~]-> {minus, {num, 0}, {num, list_to_integer(parser_read_full_number(Tail))}};
		[$~]-> {minus, {num, 0}, parser_l(Tail)};
		_   -> {num,list_to_integer([Head] ++ parser_read_full_number(Tail))}
	end.

%Gets the expression from the right
parser_r([]) -> [];
parser_r([Head|Tail]) -> 
	case [Head] of
		"+" -> parser_l(Tail);
		"-" -> parser_l(Tail);
		"/" -> parser_l(Tail);
		"*" -> parser_l(Tail);
		"(" -> parser_r(parser_skip(Tail, 1));
		[$~]-> parser_r(Tail);
		_   -> parser_r(Tail)
	end.

%Skips past (Bracked) sections
parser_skip([],_) -> [];
parser_skip(List, Needed) when Needed == 0 -> List;
parser_skip([Head|Tail], Needed) when [Head] == "(" -> parser_skip(Tail, Needed + 1);
parser_skip([Head|Tail], Needed) when [Head] /= ")" -> parser_skip(Tail, Needed);
parser_skip([_|Tail], Needed) -> parser_skip(Tail, Needed - 1).

%Scanns for numbers longer than one digit
parser_read_full_number([]) -> [];
parser_read_full_number([Head|Tail]) ->
	case [Head] of
		"+" -> [];
		"-" -> [];
		"/" -> [];
		"*" -> [];
		"(" -> [];
		")" -> [];
		[$~]-> [];
		_   -> [Head]
	end.




eval({num, Number})  -> Number;
eval({divide,R1,R2}) -> eval(R1) / eval(R2);
eval({times,R1,R2})  -> eval(R1) * eval(R2);
eval({plus,R1,R2})   -> eval(R1) + eval(R2);
eval({minus,R1,R2})  -> eval(R1) - eval(R2).

pretty({num, Number})  -> lists:flatten(io_lib:format("~p", [Number]));
pretty({plus,R1,R2})   -> "(" ++ pretty(R1) ++ "+" ++ pretty(R2) ++ ")";
pretty({minus,R1,R2})  -> "(" ++ pretty(R1) ++ "-" ++ pretty(R2) ++ ")";
pretty({times,R1,R2})  -> "(" ++ pretty(R1) ++ "*" ++ pretty(R2) ++ ")";
pretty({divide,R1,R2}) -> "(" ++ pretty(R1) ++ "/" ++ pretty(R2) ++ ")".


