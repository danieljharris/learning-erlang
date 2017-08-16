-module(db_revisit).
-export([new/0, destroy/1, write/2, delete/2, read/2, match/2]).
-include("db.hrl").

% Exercise 7-3: The db.erl Exercise Revisited
% Don't know what the book means by "Test your results using the database server developed in Exercise 5-1 in Chapter 5."

new() 				-> [].
destroy(_) 			-> ok.
write(Data, Db) 	-> [Data | Db].
delete(Data, Db) 	-> Db -- match(Data, Db).

read(_, [])										-> {error, key_not_found};
read(#data{key=Key}, [New = #data{key=Key}|_])	-> {ok, New#data.data};
read(#data{key=Key}, [_|Tail])					-> read( #data{key=Key}, Tail ).

match(_, [])										-> {error, data_not_found};
match(#data{data=Data}, [New = #data{data=Data}|_])	-> {ok, New};
match(#data{data=Data}, [_|Tail])					-> match( #data{data=Data}, Tail ).