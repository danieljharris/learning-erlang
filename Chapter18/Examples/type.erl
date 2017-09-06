%% @author Daniel Harris

-module(type).

-export([test/0, create_tables/1, close_tables/0]).

-type(plan()    :: prepay  | postpay  ).
-type(status()  :: enabled | disabled ).
-type(service() :: atom()             ).

-record(usr, {msisdn            ::integer(),
              id                ::integer(),
              status = enabled  ::status(),
              plan              ::plan(),
              services = []     ::[service()]
}).


-spec(create_tables(FileName::string()) -> {ok, integer()} | {error, atom()}).
create_tables(FileName) ->
  {error, test}.

-spec(close_tables() -> ok | {error, atom()}).
close_tables() ->
  ok.

% This is a comment
%% @doc Hello World
%% This does stuff
%% {@link test/0. 'test/0'}
-spec(test() -> ok | {error, plan()}).
test() -> ok.
