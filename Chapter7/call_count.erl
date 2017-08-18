-module(call_count).
-export([count/2]).
-export([counter/1]).


% Exercise 7-7: Counting Calls
% How can you use the Erlang macro facility to count the number of calls to a particular function in a particular module?

% No idea how to go about doing this? Does it want me to give it a file name of a file with erlang code
% in it and then search the file for every call to a module? Or does it want me to make something that
% checks how many times a module is called from the current module?

% I just decided to make a program that given a file will count the ammount of words (Which can be "Module:Function")

%%Example:
% call_count:count("/Users/daniel.harris/Documents/GitErlang/learning-erlang/Chapter7/call_count.erl", "file:close").

count(File, ModFun) ->
   register(counter, spawn(call_count, counter, [0])),


   {ok, OpenFile} = file:open(File, read),
   read_file(OpenFile, ModFun),

   whereis(counter)!{stat,self()},
   receive {count, Ammount} -> true end,
   Ammount.


%% counter
counter(Accumulator) ->
   receive 
      {stat, Pid} -> Pid!{count,Accumulator};

      Count -> counter(Accumulator + Count)
   end.


%% read_file
read_file(OpenFile, Word) ->
   case io:get_line(OpenFile, "") of
      eof -> file:close(OpenFile);
      Line -> 
         read_line(Line, Word), 
         read_file(OpenFile, Word)
   end.

%% read_line
read_line(Line, Word) ->
   case re:run(Line, Word, [global]) of
      {match, MatchedList} -> counter ! length(MatchedList);
      _ -> ok
   end.