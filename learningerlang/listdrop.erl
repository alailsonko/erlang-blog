-module(listdrop).
-export([falls/1]).

falls(List) -> falls(List,[]).

falls([], Results) -> Results;
falls([Head|Tail], Results) -> falls(Tail, [drop:fall_velocity(element(1,Head),element(2,Head)) | Results]).
