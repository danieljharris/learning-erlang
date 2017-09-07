-module(db_node).
-export([start/0, stop/0]).

-export([init/0, loop/1]).

-vsn(1.0).

% Exercise 11-1: Distributed Associative Store (Database Node)

% Node interface ------------------------------------------------------------------
start()       -> register(db_server, spawn(db_node, init, [])).
stop()        -> db_server ! stop.
% Node interface ------------------------------------------------------------------

% Backend server ------------------------------------------------------------------
init()        -> loop(db_new()).

loop(Db) ->
  receive
    {write, Key, Data}  -> loop(db_write(Key, Data, Db));
    {read, Key, Pid}    -> Pid ! db_read(Key, Db), loop(Db);
    {delete, Key}       -> loop(db_delete(Key, Db));

    stop                -> db_destroy(Db)
  end.
% Backend server ------------------------------------------------------------------

% Backend database ----------------------------------------------------------------
db_new()                    -> [].
db_destroy(_)               -> ok.
db_write(Key, Element, Db)  -> lists:append([{Key, Element}], Db).
db_delete(Key, Db)          -> lists:delete(db_read(Key, Db), Db).
db_read(Key, Db)            -> lists:keyfind(Key, 1, Db).
% Backend database ----------------------------------------------------------------
