%%%-------------------------------------------------------------------
%% @doc erlangblog public API
%% @end
%%%-------------------------------------------------------------------

-module(erlangblog_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
      Dispatch = cowboy_router:compile([
            {'_', [{"/", hello_handler, []}]}
      ]),
            {ok, _} = cowboy:start_clear(my_http_listener,
            [{port, 8080}],
            #{env => #{dispatch => Dispatch}}
    ),
    erlangblog_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
