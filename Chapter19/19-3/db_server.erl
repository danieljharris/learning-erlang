-module(db_server).
-export([start/0, stop/0, code_upgrade/0]).
-export([write/2, read/1, delete/1]).
-export([init/0, loop/1]).

-vsn(1.0).

start() ->
	register(db_server, spawn(db_server, init, [])).

stop()->
	db_server ! stop.


% Exercise 8-1: Software Upgrade During Runtime (Part 2)
code_upgrade() ->
	db_server ! {upgrade, self()}, receive Reply -> Reply end.

write(Key, Data) ->
	db_server ! {write, Key, Data}.

read(Key) ->
	db_server ! {read, self(), Key}, receive Reply -> Reply end.

delete(Key) ->
	db_server ! {delete, Key}.

init() -> loop(db:new()).

loop(Db) ->
	receive
		{write, Key, Data} ->
			loop(db:write(Key, Data, Db));

		{read, Pid, Key} ->
			Pid ! db:read(Key, Db),
			loop(Db);

		{delete, Key} ->
			loop(db:delete(Key, Db));

		{upgrade, Pid} ->
			NewDb = db:code_upgrade(Db),
			Pid ! NewDb,
			db_server:loop(NewDb);

		stop ->
			db:destroy(Db)
	end.
