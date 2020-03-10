directly_above(bicycle,pencil).
directly_above(camera,butterfly).
left_of(pencil,hourglass).
left_of(hourglass,butterfly).
left_of(butterfly,fish).

left_of(a,b).
directly_above(b,c).
left_of(c,d).
directly_above(d,e).
left_of(e,f).
directly_above(f,g).
left_of(g,h).

right_of(X,Y) :-
    left_of(Y,X).
below(X,Y) :-
    directly_above(Y,X).
left_of(X,Y) :-
    X \= Z,
    left_of(X,Z),
    left_of(Z,Y),
    Z \= Y.
above(X,Y) :- directly_above(X,Y).
above(X,Y) :-
    directly_above(X,Z),
    above(Z,Y).
same_level_above(X,Y) :-
    left_of(X,Y);
    left_of(Y,X);
    directly_above(X,A),
    directly_above(Y,B),
    same_level_below(A,B).
same_level_below(X,Y) :-
    left_of(X,Y);
    left_of(Y,X);
    below(X,A),
    below(Y,B),
    same_level_below(A,B).
same_level(X,Y) :-
    left_of(X,Y);
    left_of(Y,X);
    same_level_above(X,Y);
    same_level_below(X,Y).
higher_no_re(X,Y,_) :- above(X,Y).
higher_no_re(X,Y,L) :-
    same_level(X,Z),
    \+ member(Z,L),
    higher_no_re(Z,Y,[Z|L]).
higher_no_re(X,Y,_) :-
    directly_above(X,Z),
    (same_level(Z,Y);higher_no_re(Z,Y,[Z,Y])).
higher(X,Y) :-
    higher_no_re(X,Y,[X,Y]).