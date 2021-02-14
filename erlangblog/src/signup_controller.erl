-module(signup_controller).
-behaviour(cowboy_handler).

-export([init/2]).

json_to_map(Data) -> jsx:decode(Data).
map_to_json(Data) -> jsx:encode(Data).


username_validation(Username) -> Username,
    if 
        Username == <<>> -> 
            {false, <<"{\"error\":\"username is required\"}">>};
        true -> 
            true
    end.
email_validation(Email) -> 
    Email,
    EmailSchema = [{<<"email">>, email}], 
    EmailInput =  [{<<"email">>, Email}],
    IsEmailOkay = element(1, liver:validate(EmailSchema, EmailInput)),
    if 
        Email == <<>> ->
            {false, <<"{\"error\":\"email is required\"}">>};
        ok =/= IsEmailOkay ->
            {false, <<"{\"error\":\"email is not valid\"}">>};
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
    EmailSchema2 = [{<<"email">>, email}], 
    EmailInput2 =  [{<<"email">>, Email}],
    io:format("~p.~n", [element(1, liver:validate(EmailSchema2, EmailInput2))]),
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
            Req = cowboy_req:reply(400,
                #{<<"content-type">> => <<"application/json">>},
                element(2, UsernameValid),
                Req1),
            {ok, Req, State};
        element(1, EmailValid) == false -> 
            Req = cowboy_req:reply(400,
                #{<<"content-type">> => <<"application/json">>},
                element(2, EmailValid),
                Req1),
            {ok, Req, State};
        element(1, PasswordValid) == false -> 
            Req = cowboy_req:reply(400,
                #{<<"content-type">> => <<"application/json">>},
                element(2, PasswordValid),
                Req1),
            {ok, Req, State};
        element(1,PasswordConfirmValid) == false -> 
            Req = cowboy_req:reply(400,
                #{<<"content-type">> => <<"application/json">>},
                element(2, PasswordConfirmValid),
                Req1),
            {ok, Req, State};
        true ->
            AddAccountWithoutPasswordConfirm = maps:remove(<<"passwordConfirm">>, AddAccount),
            {ok, Salt} = bcrypt:gen_salt(),
            {ok, Hash} = bcrypt:hashpw(maps:get( <<"password">>, AddAccountWithoutPasswordConfirm), Salt),
            AddAccountWithHashedPassword = maps:put(<<"password">>, Hash, AddAccountWithoutPasswordConfirm),
            io:format("~p hash:~p.~n", [AddAccountWithHashedPassword, Hash]),
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
            MessageDB = epgsql:execute_batch(C, "INSERT INTO users (username, email, password) VALUES ($1, $2, $3) RETURNING id",
              [[
            maps:get(<<"username">>, AddAccountWithHashedPassword), 
            maps:get(<<"email">>, AddAccountWithHashedPassword), 
            maps:get(<<"password">>, AddAccountWithHashedPassword)
            ]]
        ),
        io:format("~p.~n", [element(1, lists:last(element(2, MessageDB)))]),
        IsOkay = element(1, lists:last(element(2, MessageDB))),
        ok = epgsql:close(C),
        if 
            IsOkay =/= ok ->
                Req = cowboy_req:reply(200,
                #{<<"content-type">> => <<"application/json">>},
                <<"{\"error\":\" username or email already exists.\"}">>,
                Req1),
                {ok, Req, State};
            true -> 
                CreatedAccount = maps:remove(<<"password">>, AddAccountWithHashedPassword),
                ReturnAccount = map_to_json(CreatedAccount),
                Req = cowboy_req:reply(200,
                    #{<<"content-type">> => <<"application/json">>},
                    ReturnAccount,
                    Req1
                ),
                {ok, Req, State}
        end;
        true -> 
                true
    end.