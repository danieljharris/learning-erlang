-module(echoServer_tests).
-import(echoServer, [start/0, print/1, stop/0, server_fun/0]).

% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").

start_test_() ->
  {spawn,
    {setup,
     fun start_setup/0,     % setup function
     fun start_cleanup/1,   % teardown function
     fun start_test/1       % instantiator
    }
  }.

start_setup() -> ok.
start_cleanup(_) -> stop().
start_test(_) -> [?_assertMatch(true, start())].

stop_test_() ->
  {spawn,
    {setup,
     fun stop_setup/0,     % setup function
     fun stop_cleanup/1,   % teardown function
     fun stop_test/1       % instantiator
    }
  }.

stop_setup() -> start().
stop_cleanup(_) -> ok.
stop_test(_) -> [?_assertMatch(stop, stop())].

print_test_() ->
  {spawn,
    {setup,
     fun print_setup/0,     % setup function
     fun print_cleanup/1,   % teardown function
     fun print_test/1       % instantiator
    }
  }.

print_setup() -> start().
print_cleanup(_) -> stop().
print_test(_) ->
  [?_assertMatch({message, "Hello World"}, print("Hello World"))].
