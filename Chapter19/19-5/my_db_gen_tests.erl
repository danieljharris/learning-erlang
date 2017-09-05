-module(my_db_gen_tests).
-import(my_db_gen, [start_link/0, stop/0, write/2, delete/1, read/1, match/1]).

% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").



%% code:add_path("my_db-3.0/ebin/").



start_link_test_() ->
  {spawn,
    {setup,
     fun start_link_setup/0,     % setup function
     fun start_link_cleanup/1,   % teardown function
     fun start_link_test/1       % instantiator
    }
  }.

start_link_setup() -> ok.
start_link_cleanup(_) -> stop().
start_link_test(_) -> [ ?_assertMatch({ok, _}, start_link()) ].

stop_test_() ->
  {spawn,
    {setup,
     fun stop_setup/0,     % setup function
     fun stop_cleanup/1,   % teardown function
     fun stop_test/1       % instantiator
    }
  }.

stop_setup() -> start_link().
stop_cleanup(_) -> ok.
stop_test(_) -> [ ?_assertMatch(ok, stop()) ].

write_test_() ->
  {spawn,
    {setup,
     fun write_setup/0,     % setup function
     fun write_cleanup/1,   % teardown function
     fun write_test/1       % instantiator
    }
  }.

write_setup() -> start_link().
write_cleanup(_) -> stop().
write_test(_) -> [ ?_assertMatch(ok, write(a,b)) ].

delete_test_() ->
  {spawn,
    {setup,
     fun delete_setup/0,     % setup function
     fun delete_cleanup/1,   % teardown function
     fun delete_test/1       % instantiator
    }
  }.

delete_setup() ->
  start_link(),
  write(a,b).
delete_cleanup(_) -> stop().
delete_test(_) -> [ ?_assertMatch(ok, delete(a)) ].


read_test_() ->
  {spawn,
    {setup,
     fun read_setup/0,     % setup function
     fun read_cleanup/1,   % teardown function
     fun read_test/1       % instantiator
    }
  }.

read_setup() ->
  start_link(),
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
read_cleanup(_) -> stop().
read_test(_) ->
  [?_assertMatch({ok, 2},     read(1)     ),
   ?_assertMatch({ok, 11},    read(10)    ),
   ?_assertMatch({ok, 101},   read(100)   ),
   ?_assertMatch({ok, 1001},  read(1000)  ),
   ?_assertMatch({ok, 10001}, read(10000) ),
   ?_assertMatch({error, instance}, read(bob))
  ].


match_test_() ->
  {spawn,
    {setup,
     fun match_setup/0,     % setup function
     fun match_cleanup/1,   % teardown function
     fun match_test/1       % instantiator
    }
  }.

match_setup() ->
  start_link(),
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
match_cleanup(_) -> stop().
match_test(_) ->
  [?_assertMatch([1],     match(2)     ),
   ?_assertMatch([10],    match(11)    ),
   ?_assertMatch([100],   match(101)   ),
   ?_assertMatch([1000],  match(1001)  ),
   ?_assertMatch([10000], match(10001) ),
   ?_assertMatch({error, instance}, read(bob))
  ].
