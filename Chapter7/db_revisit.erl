-module(db_revisit).
-export([new/0, destroy/1, write/2, delete/2, read/2, match/2]).
-include("db.hrl").

% Exercise 7-3: The db.erl Exercise Revisited
% Don't know what the book means by "Test your results using the database server developed in Exercise 5-1 in Chapter 5."

new()             -> [].
destroy(_)        -> ok.
write(Db, Data)   -> [Data | Db].
delete(Db, Data)  -> Db -- match(Db, Data).

read([],_)                                           -> {error, key_not_found};
read([#data{key=Key, data=Data}|_], #data{key=Key})	  -> {ok, Data};
read([_|Tail],                      Find)             -> read(Tail, Find).

match([], _)                                          -> {error, data_not_found};
match([New = #data{data=Data}|_],   #data{data=Data}) -> {ok, New};
match([_|Tail],                     Find)             -> match(Tail, Find).
