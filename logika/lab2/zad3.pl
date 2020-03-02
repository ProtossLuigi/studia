arc(a,b).
arc(b,c).
arc(c,a).

reach(X,[X]).
reach()

osiagalny(X,Y) :- reach(X,L), member(Y,L).