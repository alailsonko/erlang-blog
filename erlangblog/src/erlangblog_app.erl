%%%-------------------------------------------------------------------
%% @doc erlangblog public API
%% @end
%%%-------------------------------------------------------------------

-module(erlangblog_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
      Conn = #{
host => "localhost",
username => "postgres",
password => "docker",
database => "postgres",
port => 5432,
timeout => 4000
},
      {ok, C} = epgsql:connect(Conn),
      io:format("~p db connected.~n",[C]),
      pgsql_migration:use_driver(epgsql),
      pgsql_migration:migrate(C, "src/migration"),
      ok = epgsql:close(C),
      Dispatch = cowboy_router:compile([
            {'_', [{"/signup", signup_controller, []}]}
      ]),
            {ok, _} = cowboy:start_clear(my_http_listener,
            [{port, 8080}],
            #{env => #{dispatch => Dispatch}}
    ),
    erlangblog_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
