-module(my_db_gen_tests).
-import(my_db_gen, [start_link/0, stop/0, write/2, delete/1, read/1, match/1]).

% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").



%% code:add_path("my_db-3.0/ebin/").

everything_test_() ->
  {spawn,
    {setup,
     fun everything_setup/0,     % setup function
     fun everything_cleanup/1,   % teardown function
     fun everything_test/1       % instantiator
    }
  }.

everything_setup() -> ok.
everything_cleanup(_) -> ok.
everything_test(_) ->
  [?_assertMatch({ok, _}, start_link()),
   ?_assertEqual(ok, write(a,b)),
   ?_assertEqual(ok, delete(a)),
   read_tester(),
   match_tester(),
   ?_assertEqual(ok, stop())
  ].

read_tester() ->
  {spawn,
    {setup,
     fun read_setup/0,     % setup function
     fun read_cleanup/1,   % teardown function
     fun read_test/1       % instantiator
    }
  }.

read_setup() ->
  Acc =
    fun(F, Num) ->
      case Num of
        0 ->
          ok;
        _Other ->
          write(Num, Num+1),
          F(F, Num - 1)
      end
    end,
  Acc(Acc, 10000).
read_cleanup(_) -> ok.
read_test(_) ->
  [?_assertMatch({ok, 2},     read(1)     ),
   ?_assertMatch({ok, 11},    read(10)    ),
   ?_assertMatch({ok, 101},   read(100)   ),
   ?_assertMatch({ok, 1001},  read(1000)  ),
   ?_assertMatch({ok, 10001}, read(10000) ),
   ?_assertMatch({error, instance}, read(bob))
  ].


match_tester() ->
  {spawn,
    {setup,
     fun match_setup/0,     % setup function
     fun match_cleanup/1,   % teardown function
     fun match_test/1       % instantiator
    }
  }.

match_setup() -> ok.
match_cleanup(_) -> ok.
match_test(_) ->
  [?_assertMatch([1],     match(2)     ),
   ?_assertMatch([10],    match(11)    ),
   ?_assertMatch([100],   match(101)   ),
   ?_assertMatch([1000],  match(1001)  ),
   ?_assertMatch([10000], match(10001) ),
   ?_assertMatch({error, instance}, read(bob))
  ].
