-module(usr_db_tests).
-import(usr_db, [get_path/0, create_tables/1, close_tables/0, add_usr/1,
                 update_usr/1, delete_usr/1, lookup_id/1, restore_backup/0,
                 lookup_msisdn/1, delete_disabled/0]).
-include("usr.hrl").

% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").

path() ->
  "/Users/daniel.harris/Documents/GitErlang/learning-erlang/Chapter19/Examples/DB".

setup1_test_() ->
  {spawn,
    {setup,
      fun () -> create_tables( path() ) end,          % setup
      fun (_) -> ?cmd( "rm " ++ path() ) end,         % cleanup
      ?_assertMatch( {error,instance}, lookup_id(1) ) % test
    }
  }.

setup2_test_() ->
  {spawn,
    {setup,
      fun () ->
        create_tables( path() ),
        Seq = lists:seq(1,100000),
        Add =
          fun(Id) ->
            add_usr(#usr{msisdn = 700000000 + Id,
                         id = Id,
                         plan = prepay,
                         services = [data, sms, lbs]
            })
          end,
        lists:foreach(Add, Seq) % setup
      end,
      fun (_) -> ?cmd( "rm " ++ path() ) end, % cleanup
      ?_assertMatch({ok, #usr{status = enabled}}, lookup_msisdn(700000001) ) % test
    }
  }.
