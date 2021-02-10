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
            {false, <<"{\"error\":\"email is required\"}">>};
        true -> 
            true
    end.
password_validation(Password) -> Password,
    if 
        Password == <<>> ->
            {false, <<"{\"error\":\"password is required\"}">>};
        true -> 
            true
    end.   
passwordConfirm_validation(PasswordConfirm, Password) -> PasswordConfirm, Password,
    if 
        PasswordConfirm == <<>> ->
            {false, <<"{\"error\":\"passwordConfirm is required\"}">>};
        PasswordConfirm =/= Password ->
            {false, <<"{\"error\":\"Password and passwordConfirm must match\"}">>};
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
    io:format("~p.~n", [passwordConfirm_validation(PasswordConfirm, Password)]),
    UsernameValid = username_validation(Username),
    EmailValid = email_validation(Email),
    PasswordValid = password_validation(Password),
    PasswordConfirmValid = passwordConfirm_validation(PasswordConfirm, Password),
    if 
    
        element(1,UsernameValid) == false -> 
            Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"application/json">>},
                element(2, UsernameValid),
                Req1),
            {ok, Req, State};
        element(1, EmailValid) == false -> 
            Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"application/json">>},
                element(2, EmailValid),
                Req1),
            {ok, Req, State};
        element(1, PasswordValid) == false -> 
            Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"application/json">>},
                element(2, PasswordValid),
                Req1),
            {ok, Req, State};
        element(1,PasswordConfirmValid) == false -> 
            Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"application/json">>},
                element(2, PasswordConfirmValid),
                Req1),
            {ok, Req, State};
        true ->
            Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"application/json">>},
                Data,
                Req1),
            {ok, Req, State}

    end.