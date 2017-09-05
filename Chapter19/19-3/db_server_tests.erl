-module(db_server_tests).
-import(db_server, [start/0, stop/0, code_upgrade/0, write/2, read/1, delete/1]).


% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").

upgrade_test_() ->
  {spawn,
    {setup,
     fun upgrade_setup/0,     % setup function
     fun upgrade_cleanup/1,   % teardown function
     fun upgrade_test/1       % instantiator
    }
  }.

upgrade_setup() ->
  start(),
  write(1, 2),
  write(3, 4),
  code_upgrade().

upgrade_cleanup(_) -> stop().

%% Here you would check the db has been upgraded to the new format
upgrade_test(NewDb) ->
  [?_assertMatch([{3, 4}, {1, 2}], NewDb)].
