le(a,a).
le(a,b).
le(b,b).
le(c,c).
le(b,c).
le(a,c).
le(c,b).

czesciowy_porzadek :-
    \+ (
            (le(X,Y);le(Y,X)),
            \+ le(X,X)
        ),
    \+ (
            le(X,Y),
            le(Y,Z),
            \+ le(X,Z)
        ),
    \+ (
            le(X,Y),
            le(Y,X),
            X \= Y
        ).