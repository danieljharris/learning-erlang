-module(otp_testing_tests).
-import(otp_testing, [start_link/1, init/1, set_status/2, delete_disabled/0,
                      handle_call/3, stop/0, handle_cast/2, terminate/2,
                      add_usr/2]).

% -define(NOTEST, true).
-include_lib("eunit/include/eunit.hrl").

path() -> "/Users/daniel.harris/Documents/GitErlang/learning-erlang/Chapter19/19-4/DB".


%% Note -----------------------------------------------------------------
% For some reason I can only test one thing at a time, otherwise they
% somehow over lap and stop eachother from working
%% Note -----------------------------------------------------------------

start_link_test_() ->
  {spawn,
    {setup,
     fun start_link_setup/0,     % setup function
     fun start_link_cleanup/1,   % teardown function
     fun start_link_test/1       % instantiator
    }
  }.
start_link_setup() -> ok.
start_link_cleanup(_) -> delete_disabled(), stop().
start_link_test(_) -> [ ?_assertMatch({ok, _}, start_link(path())) ].


% stop_test_() ->
%   {spawn,
%     {setup,
%      fun stop_setup/0,     % setup function
%      fun stop_cleanup/1,   % teardown function
%      fun stop_test/1       % instantiator
%     }
%   }.
% stop_setup() -> start_link(path()).
% stop_cleanup(_) -> ok.
% stop_test(_) -> [ ?_assertMatch(ok, stop()) ].


% add_test_() ->
%   {spawn,
%     {setup,
%      fun add_setup/0,     % setup function
%      fun add_cleanup/1,   % teardown function
%      fun add_test/1       % instantiator
%     }
%   }.
% add_setup() ->
%   start_link(path()).
% add_cleanup(_) -> delete_disabled(), stop().
% add_test(_) -> [ ?_assertMatch(ok, add_usr(dan, 123)) ].


% write_test_() ->
%   {spawn,
%     {setup,
%      fun write_setup/0,     % setup function
%      fun write_cleanup/1,   % teardown function
%      fun write_test/1       % instantiator
%     }
%   }.
% write_setup() ->
%   start_link(path()),
%   add_usr(dan, 123).
% write_cleanup(_) -> delete_disabled(), stop().
% write_test(_) -> [ ?_assertMatch(ok, set_status(dan, enabled)) ].
