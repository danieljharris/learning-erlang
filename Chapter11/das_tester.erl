-module(das_tester).
-export([test/0]).

-include("nodes.hrl").

-vsn(1.0).

% Exercise 11-1: Distributed Associative Store (Test Module)




%%Notes --------------------------------------------------------------------

% I had everything working, I'm now almost finished with the load balancer
% Then I need to move on to making the System Monitoring task of 11-2

%%Notes --------------------------------------------------------------------





test() ->
	das:open(),

	%% Add & Lookup Testing
	das:add(dan, cardiff),
	das:add(bob, london),

	% Node One
	case das:lookup(dan) of
		{dan, cardiff} -> AddLook_One_Result = working;
		_ -> AddLook_One_Result = not_working
	end,
	% Node Two
	case das:lookup(bob) of
		{bob, london} -> AddLook_Two_Result = working;
		_ -> AddLook_Two_Result = not_working
	end,
	
	% Crossover
	case das:lookup(bob) of
		{bob, london} ->
			case das:lookup(dan) of
				{dan, cardiff} ->
					AddLook_Crossover_Result = working;
				_ -> AddLook_Crossover_Result = not_working
			end;

		_ -> AddLook_Crossover_Result = not_working
	end,
	
	%% Remove & Lookup Testing
	das:remove(dan),
	das:remove(bob),

	% Node One
	case das:lookup(dan) of
		false -> RemoveLook_One_Result = working;
		_ -> RemoveLook_One_Result = not_working
	end,
	% Node Two
	case das:lookup(bob) of
		false -> RemoveLook_Two_Result = working;
		_ -> RemoveLook_Two_Result = not_working
	end,
	
	% Crossover
	case das:lookup(bob) of
		false ->
			case das:lookup(dan) of
				false ->
					RemoveLook_Crossover_Result = working;
				_ -> RemoveLook_Crossover_Result = not_working
			end;

		_ -> RemoveLook_Crossover_Result = not_working
	end,





	% Closes down nodes
	das:close(),
	

	io:format("
		Add & Look:	Node One:	~p
		Add & Look:	Node Two:	~p
		Add & Look:	Crossover:	~p

		Remove & Look:	Node One:	~p
		Remove & Look:	Node Two:	~p
		Remove & Look:	Crossover:	~p~n
		", [
		AddLook_One_Result,
		AddLook_Two_Result,
		AddLook_Crossover_Result,

		RemoveLook_One_Result,
		RemoveLook_Two_Result,
		RemoveLook_Crossover_Result
		]).
