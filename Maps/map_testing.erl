-module(map_testing).
-export([test/0]).

test() ->
  Map1 = maps:new(),
  Map2 = maps:put(dan, cardiff, Map1),
  Map3 = maps:put(bob, london, Map2),
  Map4 = maps:put(sam, london, Map3),
  Map5 = maps:update(bob, scotland, Map4),

  io:format("Dan: ~p~n", [maps:get(dan, Map5)]),
  io:format("Bob: ~p~n", [maps:get(bob, Map5)]),
  io:format("Sam: ~p~n", [maps:get(sam, Map5)]),

  io:format("w/ Dan: ~p~n", [maps:with([dan], Map5)]),
  io:format("w/ Bob: ~p~n", [maps:with([bob], Map5)]),
  io:format("w/ Dan & Bob: ~p~n", [maps:with([dan, bob], Map5)]),

  io:format("w/o Dan: ~p~n", [maps:without([dan], Map5)]),
  io:format("w/o Bob: ~p~n", [maps:without([bob], Map5)]),
  io:format("w/o Dan & Bob: ~p~n", [maps:without([dan, bob], Map5)]),
  match(Map5),
  match(maps:without([dan], Map5)),
  match(maps:without([dan, bob], Map5)).

match(#{ dan := cardiff }) -> io:format("Dan, Cardiff.~n", []);
match(#{ bob := X }) when X == scotland -> io:format("Bob, London.~n", []);
match(#{ sam := wales }) -> io:format("Sam, Wales.~n", []);
match(_Other) -> io:format("No match.~n", []).
