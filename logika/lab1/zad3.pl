above(bicycle,pencil).
above(camera,butterfly).
left_of(pencil,hourglass).
left_of(hourglass,butterfly).
left_of(butterfly,fish).

right_of(X,Y) :-
    left_of(Y,X).
below(X,Y) :-
    above(Y,X).
left_of_rec(X,Y) :- left_of(X,Y).
left_of_rec(X,Y) :-
    left_of(X,Z),
    left_of_rec(Z,Y).
above_rec(X,Y) :- above(X,Y).
above_rec(X,Y) :-
    above(X,Z),
    above_rec(Z,Y).
higher(X,Y) :-
    above_rec(X,Y);
    above_rec(X,A),
    (
        left_of_rec(A,Y);
        left_of_rec(Y,A)
    ).