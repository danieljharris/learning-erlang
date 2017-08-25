-module(reliable_mutex).
-export([test/0]).
-export([start/0, stop/0]).
-export([wait/0, signal/0]).
-export([init/0, start_wait/0, start_wait_crash/0]).

% Exercise 6-2: A Reliable Mutex Semaphore

test() ->
  catch start(),
  spawn(reliable_mutex, start_wait_crash, []),
  spawn(reliable_mutex, start_wait, []),
  spawn(reliable_mutex, start_wait, []),
  spawn(reliable_mutex, start_wait, []),
  ok.

start_wait_crash() ->
  io:format("~p: waiting~n", [self()]),
  wait(),
  io:format("~p: crashing~n", [self()]).

start_wait() ->
  io:format("~p: waiting~n", [self()]),
  wait(),
  io:format("~p: finished~n", [self()]),
  signal().

start() ->
  register(mutex, spawn(reliable_mutex, init, [])).

stop() ->
  mutex ! stop.

wait() ->
  mutex ! {wait, self()},
  receive ok -> ok end.

signal() ->
  mutex ! {signal, self()}, ok.

init() ->
  process_flag(trap_exit, true),
  free().


free() ->
  receive
    {wait, Pid} ->
        Pid ! ok,
        busy(Pid);
    stop ->
      terminate()
  end.


%% Link method ----------------------------
busy(Pid) ->
  try link(Pid) of
    true -> ok
  catch
    _:_ -> free()
  end,

  receive
    {signal, Pid} ->
      unlink(Pid),
      free();

    {'EXIT', _Pid, _Reason} ->
      unlink(Pid),
      free()
  end.
%% Link method ----------------------------

%% Monitor method -------------------------
% busy(Pid) ->
%   Reference = erlang:monitor(process, whereis(cell)),
%   receive
%     {signal, Pid} ->
%       erlang:demonitor(Reference),
%       free();

%     {'DOWN', _Reference, process, _Pid, _Reason} ->
%       erlang:demonitor(Reference),
%       free()
%   end.
%% Monitor method -------------------------


terminate() ->
  receive
    {wait, Pid} ->
      exit(Pid, kill),
      terminate()
  after 0 -> ok
  end.
