-module(dist2).
-export([t/1, s/0, m/1]).

t(Pid) ->
	erlang:set_cookie(node(), cake),
	Pid ! hello.

s() -> 
	register(server,self()),
	Result = loop(),
	unregister(server),
	Result	.

loop() ->
	receive
		{M, Pid} ->
			Pid!{yo, M, self()}

	after 10000 -> {error, timeout}
	end.

m(Place) ->
	{ server, Place }!{ hi, self()} ,
	receive
		Message -> Message

	after 10000 -> {error, timeout}
	end.