head([_],[]).
head([X|L1],[X|L2]) :- head(L1,L2).
equation([X],X,X) :- !.
equation([X|L],Y,R) :-
    equation(L,RR,W),
    (
        Y is X+RR,
        R = X+W;
        Y is X-RR,
        R = X-W;
        Y is X*RR,
        R = X*W;
        RR =\= 0,
        Y is X/RR,
        R = X/W
    ).
equation(L,Y,R) :-
    head(L,Head),
    equation(Head,RR,W),
    last(L,X),
    (
        Y is RR+X,
        R = W+X;
        Y is RR-X,
        R = W-X;
        Y is RR*X,
        R = W*X;
        X =\= 0,
        Y is RR/X,
        R = W/X
    ).
wyrazenie(L,Y,R) :- equation(L,Y,R), !.