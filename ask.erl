-module(ask).
-export([term/0]).
-export([chars/0]).
-export([line/0]).

line() ->
	Planemo = get_planemo(),
	Distance = get_distance(),
	drop:fall_velocity(Planemo, Distance).

get_planemo() ->
	io:format("Where are you?~n"),
	io:format(" 1. Earth ~n"),
	io:format(" 2. Earth's Moon~n"),
	io:format(" 3. Mars~n"),
	Answer = io:get_line("Which? > "),
	Value = hd(Answer),
	char_to_planemo(Value).

char_to_planemo(Char) ->
	if
		[Char] == "1" -> earth;
		Char == $2 -> moon;
		Char == 51 -> mars
	end.

get_distance() ->
	Input = io:get_line("How far? (meters) > "),
	Value = string:strip(Input, right, $\n),
	{Distance, _} = string:to_integer(Value),
	Distance.

chars() ->
	io:format("Which planemo are you on?~n"),
	io:format(" 1. Earth ~n"),
	io:format(" 2. Earth's Moon~n"),
	io:format(" 3. Mars~n"),
	io:get_chars("Which? > ",1).

term() ->
	Input = io:read("What {planemo, distance} ? >>"),
	process_term(Input).

process_term({ok, Term}) when is_tuple(Term) ->
	Velocity = drop:fall_velocity(element(2,Term)),
	io:format("Yields ~w. ~n", [Velocity]),
	term();

process_term({ok, quit}) ->
	io:format("Goodbye. ~n");
	% does not call term() again

process_term({ok, _}) ->
	io:format("You must enter a tuple.~n"),
	term();

process_term({error, _}) ->
	io:format("You must enter a tuple with correct syntax.~n"),
	term().


