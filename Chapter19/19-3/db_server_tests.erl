-module(db_server_tests).
-import(db_server, [start/0, stop/0, code_upgrade/0, write/2, read/1, delete/1]).

-include_lib("eunit/include/eunit.hrl").

upgrade_test_() ->
  {setup,
   fun upgrade_setup/0,     % setup function
   fun upgrade_cleanup/1,   % teardown function
   fun upgrade_test/1       % instantiator
  }.

upgrade_setup() ->

  % Loads first version of the db
  code:purge(db),
  compile:file("db"),
  code:load_file(db),

  % Dummy data
  start(),
  write(1, 2),
  write(3, 4),

  % Updated the db to the new version
  code:purge(db),
  compile:file("patches/db"),
  code:load_file(db),

  code_upgrade().

upgrade_cleanup(_) -> stop().

%% Here you would check the db has been upgraded to the new format
upgrade_test(NewDb) ->
  [?_assertEqual({2,{3,4,{1,2,nil,nil},nil}}, NewDb)].
