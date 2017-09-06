-module(ets_tracing).
-export([trace/0]).
-export([server_start/0, server_start/1]).
-export([crash/0]).

% Exercise 17-3: Tracing ETS Table Entries

% 1) First run this on a node to cause {'EXIT', error} to be inserted
trace() ->
  PortFun = dbg:trace_port(ip, 1234),
  dbg:tracer(port, PortFun),

  dbg:p(all,[c]),


  % dbg:fun2ms(fun([_,{'EXIT', _}]) -> message(caller()); ([_,{'EXIT', _, _}]) -> message(caller()) end).
  dbg:tp({ets, insert, 2}, [{['_',{'EXIT','_'}],[],[{message,{caller}}]},
    {['_',{'EXIT','_','_'}],[],[{message,{caller}}]}]),
  dbg:tpl({ets, insert, 2}, [{['_',{'EXIT','_'}],[],[{message,{caller}}]},
    {['_',{'EXIT','_','_'}],[],[{message,{caller}}]}]),


  spawn(ets_tracing, crash, []).

% 2) Then start the server on a diffrent node to receive the trace information
server_start() -> dbg:trace_client(ip, 1234).
server_start(Pid) -> dbg:stop_trace_client(Pid).

crash() ->
  ets:new(table, [named_table]),
  ets:insert(table, {'EXIT', error}),
  ets:insert(table, {'EXIT', pid, error}),
  ets:delete(table).
