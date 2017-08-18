-module(enum).
-export([day/1, month/1]).

% Exercise 7-8: Enumerated Types

-define(DAY(Day),
	case Day of
		monday		-> 1;
		tuesday		-> 2;
		wednesday	-> 3;
		thursday	-> 4;
		friday		-> 5;
		saturday	-> 6;
		sunday		-> 7
	end
	).

-define(MONTH(Day),
	case Day of
		january		-> 1;
		february	-> 2;
		march		-> 3;
		april		-> 4;
		may			-> 5;
		june		-> 6;
		july		-> 7;
		august		-> 8;
		september	-> 9;
		october		-> 10;
		november	-> 11;
		december	-> 12
	end
	).


day(Day) -> ?DAY(Day).
month(Month) -> ?MONTH(Month).