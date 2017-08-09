-module(even).
-export([is_even/1]).
-export([is_odd/1]).
-export([data_Type/1]).
-export([contains/2]).

is_even([]) -> [];
is_even([Head|Tail]) when Head rem 2 == 0 ->[Head|is_even(Tail)];
is_even([_|Tail]) -> is_even(Tail);
is_even(Int) ->
   case Int rem 2 of
      1 -> false;
      0 -> true
   end.

is_odd(Val) when is_list(Val) -> Val -- is_even(Val);
is_odd(Int) -> not(is_even(Int)).

data_Type(Val) when is_integer(Val) -> {dataType, integer};
data_Type(Val) when is_float(Val) -> {dataType, float};
data_Type(Val) when is_boolean(Val) -> {dataType, boolean};
data_Type(Val) when is_function(Val) -> {dataType, function};
data_Type(Val) when is_atom(Val) -> {dataType, atom};
data_Type(Val) when is_list(Val) -> {dataType, list};
data_Type(Val) when is_map(Val) -> {dataType, map};
data_Type(Val) when is_tuple(Val) -> {dataType, tuple}.

contains(_,[]) -> false;
contains(Find, [Find|_]) -> true;
contains(Find, [_|Item]) -> contains(Find, Item).
