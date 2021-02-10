-module(signup_controller).
-behaviour(cowboy_handler).

-export([init/2]).

json_to_map(Data) -> jsx:decode(Data).

username_validation(Username) -> Username,
    if 
        Username == <<>> -> 
            {false, <<"{\"error\":\"username is required\"}">>};
        true -> 
            true
    end.
email_validation(Email) -> Email,
    if 
        Email == <<>> ->
            <<"{\"error\":\"email is required\"}">>;
        true -> 
            true
    end.
password_validation(Password) -> Password,
    if 
        Password == <<>> ->
            <<"{\"error\":\"password is required\"}">>;
        true -> 
            true
    end.   
passwordConfirm_validation(PasswordConfirm) -> PasswordConfirm,
    if 
        PasswordConfirm == <<>> ->
            <<"{\"error\":\"passwordConfirm is required\"}">>;
        true -> 
            true
    end.

init(Req0, State) ->
    {ok, Data, Req1} = cowboy_req:read_body(Req0),
    AddAccount = json_to_map(Data),
    io:format("~p.~n", [AddAccount]),
    Username = maps:get(<<"username">>, AddAccount),
    Email = maps:get(<<"email">>, AddAccount),
    Password = maps:get(<<"password">>, AddAccount),
    PasswordConfirm = maps:get(<<"passwordConfirm">>, AddAccount),
    io:format("~p.~n", [Username]),
    io:format("~p.~n", [username_validation(Username)]),
    io:format("~p.~n", [Email]),
    io:format("~p.~n", [email_validation(Email)]),
    io:format("~p.~n", [Password]),
    io:format("~p.~n", [password_validation(Password)]),
    io:format("~p.~n", [PasswordConfirm]),
    io:format("~p.~n", [passwordConfirm_validation(PasswordConfirm)]),
    UsernameValid = username_validation(Username),
    if element(1,UsernameValid) == false -> 
        Req = cowboy_req:reply(200,
            #{<<"content-type">> => <<"application/json">>},
            element(2, UsernameValid),
            Req1),
        {ok, Req, State};
    true ->
        Req = cowboy_req:reply(200,
            #{<<"content-type">> => <<"application/json">>},
            Data,
            Req1),
        {ok, Req, State}
    end.