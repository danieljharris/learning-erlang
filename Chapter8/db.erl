-module(db).
-export([new/0,destroy/1,write/3,delete/2,read/2,match/2]).

-vsn(1.0).


%%Exercise 3-7: Using Library Modules
new()					-> [].
destroy(_)				-> ok.
write(Key, Element, Db)	-> lists:append([{Key, Element}], Db).
delete(Key, Db) 		-> lists:delete(read(Key, Db), Db).
read(Key, Db) 			-> lists:keyfind(Key, 1, Db).
match(Element, Db) 		-> lists:keyfind(Element, 2, Db).