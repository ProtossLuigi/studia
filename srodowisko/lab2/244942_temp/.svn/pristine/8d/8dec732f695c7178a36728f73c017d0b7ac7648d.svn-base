head([_],[]).
head(L1,L2) :- L1 = [X|L3], L2 = [X|L4], head(L3,L4).
srodkowy([X],X).
srodkowy(L,X) :- head(L,Head), Head = [_|Mid], srodkowy(Mid,X).