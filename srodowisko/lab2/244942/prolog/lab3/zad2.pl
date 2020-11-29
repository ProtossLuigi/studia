max_sum_([],_,MS,MS).
max_sum_([X|L],TS,CS,MS) :-
    NTS is max(0,TS + X),
    NCS is max(CS,NTS),
    max_sum_(L,NTS,NCS,MS).

max_sum(L,X) :- max_sum_(L,0,0,X).