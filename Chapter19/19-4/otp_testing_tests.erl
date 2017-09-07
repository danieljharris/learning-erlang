-module(otp_testing_tests).
-import(otp_testing, [start_link/1, init/1, set_status/2, delete_disabled/0,
                      handle_call/3, stop/0, handle_cast/2, terminate/2,
                      add_usr/2]).

% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").

path() -> "/Users/daniel.harris/Documents/GitErlang/learning-erlang/Chapter19/19-4/DB".

everything_test_() ->
  {setup,
   fun start_link_setup/0,     % setup function
   fun start_link_cleanup/1,   % teardown function
   fun start_link_test/1       % instantiator
  }.
start_link_setup() -> ok.
start_link_cleanup(_) -> ok.
start_link_test(_) ->
  [?_assertMatch({ok, _}, start_link(path())),
   ?_assertEqual(ok, add_usr(dan, 123)),
   ?_assertEqual(ok, set_status(dan, enabled)),
   ?_assertEqual(ok, stop())
  ].
