%% @author Alailson Andrade <aalailson3@gmail.com> [https://github.com/alailsonko]
%% @doc Calculates the velocity of an object falling on Earth
%% as if it were in a vacuum (no air resistance). The distance is
%% the height frmo which the object falls, specified in meters,
%% and the function returns a velocity in meters per second.
%% @reference from a <a href="https://github.com/alailsonko">
%% Learning Erlang </a>,
%% Alailson, Br, 2021.
%% @copyright 2017 by Alailson Andrade
%% @version 0.1

-module(drop).
-export([fall_velocity/1]).
-export([fall_velocity/2]).

-spec(fall_velocity(number()) -> number()).

fall_velocity(Distance) -> math:sqrt(2 * 9.8 * Distance).

fall_velocity(Planemo, Distance) when Distance >= 0 ->
	Gravity = case Planemo of
		earth -> 9.8;
		moon -> 1.6;
		mars -> 71
	end,

	Velocity = math:sqrt(2 * Gravity * Distance),

	Description = if
		Velocity == 0 -> 'stable';
		Velocity < 5 -> 'slow';
		Velocity >= 5, Velocity < 10 -> 'moving';
		Velocity >= 10, Velocity < 20 -> 'fast';
		Velocity >= 20 -> 'speedy'
	end,
	if
		(Velocity > 40) -> io:format("Look out below!~n");
		true -> true
	end,
	Description.
