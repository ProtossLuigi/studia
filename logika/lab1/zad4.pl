led(a,c).
led(b,c).
led(c,d).
led(d,e).

le(X,Y) :- led(X,Y).
le(X,Y) :- X = Y.
le(X,Y) :- led(X,Z), le(Z,Y).

% le(X, Y) :-
%     le(X, Y, []).

% le(X, Y, A) :-
%     led(X, Y),
%     \+ memberchk((X, Y), A).   % Make sure we haven't visited this case
% le(X, Y, A) :-
%     led(X, Z),
%     \+ memberchk((X, Z), A),   % Make sure we haven't visited this case
%     le(Z, Y, [(X,Z)|A]).

maksymalny(X) :-
    \+ (
        le(X,Y),
        Y \= X
        ).

najwiekszy(X) :-
    \+ (
        (
            le(Y,Z);
            le(Z,Y)
        ),
        \+ le(Y,X)
        ).

minimalny(X) :-
    \+ (
        le(Y,X),
        Y \= X
        ).

    najmniejszy(X) :-
        \+ (
            (
                le(Y,Z);
                le(Z,Y)
            ),
            \+ le(X,Y)
            ).