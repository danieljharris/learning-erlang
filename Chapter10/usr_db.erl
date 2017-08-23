-module(usr_db).
-export([get_path/0, create_tables/1, close_tables/0, add_usr/1, update_usr/1, delete_usr/1, lookup_id/1, restore_backup/0, lookup_msisdn/1, delete_disabled/0]).
-include("usr.hrl").

-vsn(1.0).

get_path() -> "/Users/daniel.harris/Documents/GitErlang/learning-erlang/Chapter10/DB".

create_tables(FilePath) ->
	ets:new(usrRam, [named_table, {keypos, #usr.msisdn}]),
	ets:new(usrIndex, [named_table]),
	dets:open_file(usrDisk, [{file, FilePath}, {keypos, #usr.msisdn}]).

close_tables() ->
	ets:delete(usrRam),
	ets:delete(usrIndex),
	ets:close(usrDisk).

add_usr(#usr{msisdn=PhoneNo, id=CustId} = Usr) ->
	ets:insert(usrIndex, {CustId, PhoneNo}),
	update_usr(Usr).

update_usr(Usr) ->
	ets:insert(usrRam, Usr),
	dets:insert(usrDisk, Usr),
	ok.

delete_usr(PhoneNo, CustId) ->
	delete_usr(CustId).


% Still not deleteing user from usrRam 
delete_usr(CustId) ->
	PhoneNo = lookup_id(CustId),
	ets:delete(usrIndex, CustId),
	ets:delete(usrRam, PhoneNo),
	dets:delete(usrDisk, PhoneNo),
	ok.


lookup_id(CustId) ->
	case get_index(CustId) of
		{ok, PhoneNo} -> lookup_msisdn(PhoneNo);
		{error, instance} -> {error, instance}
	end.

lookup_msisdn(PhoneNo) ->
	case ets:lookup(usrRam, PhoneNo) of
		[Usr] -> {ok, Usr};
		[] -> {error, instance}
	end.

get_index(CustId) ->
	case ets:lookup(usrIndex, CustId) of
		[{CustId,PhoneNo}] -> {ok, PhoneNo};
		[] -> {error, instance}
	end.



restore_backup() ->
	Insert = fun(#usr{msisdn=PhoneNo, id=Id} = Usr) ->
		ets:insert(usrRam, Usr), ets:insert(usrIndex, {Id, PhoneNo}),
		continue
		end,
	dets:traverse(usrDisk, Insert).


delete_disabled() ->
	ets:safe_fixtable(usrRam, true),
	catch loop_delete_disabled(ets:first(usrRam)),
	ets:safe_fixtable(usrRam, false),
	ok.

loop_delete_disabled('$end_of_table') -> ok;
loop_delete_disabled(PhoneNo) ->
	case ets:lookup(usrRam, PhoneNo) of
		[#usr{status=disabled, id = CustId}] -> delete_usr(PhoneNo, CustId);
		_ -> ok
	end,
	loop_delete_disabled(ets:next(usrRam, PhoneNo)).






