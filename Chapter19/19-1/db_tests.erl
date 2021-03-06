-module(db_tests).
-import(db, [new/0, destroy/1, write/3, delete/2, read/2, match/2]).

% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").

new_test() ->
  ?assertEqual( [] , new() ).

destroy_test() ->
  ?assertEqual( ok , destroy([{1,2},{3,4},{5,6}]) ).

write_test_() ->
  [?_assertEqual([{1,     element}], write(1,     element, []) ),
   ?_assertEqual([{10,    element}], write(10,    element, []) ),
   ?_assertEqual([{100,   element}], write(100,   element, []) ),
   ?_assertEqual([{1000,  element}], write(1000,  element, []) ),
   ?_assertEqual([{10000, element}], write(10000, element, []) )
  ].

delete_test_() ->
  [?_assertEqual([], delete(1,     [{1,     element}]) ),
   ?_assertEqual([], delete(10,    [{10,    element}]) ),
   ?_assertEqual([], delete(100,   [{100,   element}]) ),
   ?_assertEqual([], delete(1000,  [{1000,  element}]) ),
   ?_assertEqual([], delete(10000, [{10000, element}]) ),
   ?_assertEqual({error, key_not_found}, delete(10000, [{10001, element}]) )
  ].

read_write_test_() ->
  {setup,
   fun read_write_setup/0,     % setup function
   fun read_write_cleanup/1,   % teardown function
   fun read_write_test/1       % instantiator
  }.

read_write_setup() ->
  NTable = new(),
  Acc =
    fun(F, Num, Table) ->
      case Num of
        0 ->
          Table;
        _Other ->
          F(F, Num - 1, write(Num, Num+1, Table))
      end
    end,
  Acc(Acc, 10000, NTable).
read_write_cleanup(_) -> ok.
read_write_test(FilledTable) ->
  [?_assertEqual({ok, 2},     read(1,     FilledTable) ),
   ?_assertEqual({ok, 11},    read(10,    FilledTable) ),
   ?_assertEqual({ok, 101},   read(100,   FilledTable) ),
   ?_assertEqual({ok, 1001},  read(1000,  FilledTable) ),
   ?_assertEqual({ok, 10001}, read(10000, FilledTable) ),
   ?_assertEqual({error, key_not_found}, read(hello, FilledTable) )
  ].


match_write_test_() ->
  {setup,
   fun match_write_setup/0,       % setup function
   fun match_write_cleanup/1,     % teardown function
   fun match_write_conditions/1   % instantiator
  }.

match_write_setup() ->
  NTable = new(),
  Acc =
    fun(F, Num, Table) ->
      case Num of
        0 ->
          Table;
        _Other ->
          F(F, Num - 1, write(Num, Num+1, Table))
      end
    end,
  [ {10001, 10001} | Acc(Acc, 10000, NTable) ].
match_write_cleanup(_) -> ok.
match_write_conditions(FilledTable) ->
  [?_assertEqual([{1,     2}],     match(2,     FilledTable) ),
   ?_assertEqual([{10,    11}],    match(11,    FilledTable) ),
   ?_assertEqual([{100,   101}],   match(101,   FilledTable) ),
   ?_assertEqual([{1000,  1001}],  match(1001,  FilledTable) ),
   ?_assertEqual([{10001, 10001}, {10000, 10001}], match(10001, FilledTable) ),
   ?_assertEqual({error, element_not_found}, match(hello, FilledTable) )
  ].
