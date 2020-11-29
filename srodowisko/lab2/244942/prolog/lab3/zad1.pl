suml([],0).
suml([X|L],Y) :-
    suml(L,Z),
    Y is X + Z.

suml_sq([],0).
suml_sq([X|L],Y) :-
    suml_sq(L,Z),
    Y is X * X + Z.

wariancja([],0).
wariancja(L,X) :-
    length(L,N),
    N > 0,
    suml(L,S1),
    suml_sq(L,S2),
    X is S2 / N - (S1 / N)^2.