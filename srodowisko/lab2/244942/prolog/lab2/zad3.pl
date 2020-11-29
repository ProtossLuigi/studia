arc(a,b).
arc(b,c).
arc(c,a).
arc(x,a).
arc(c,d).

reach(X,Y,L) :- arc(X,Y), \+ member(Y,L).
reach(X,Y,L) :- arc(X,Z), \+ member(Z,L), reach(Z,Y,[Z|L]).

osiagalny(X,Y) :- X = Y.
osiagalny(X,Y) :- reach(X,Y,[X]).