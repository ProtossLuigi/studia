permutation_num(L,L,[],R,R).
permutation_num([X|L],[X|PL],D,TR,R) :-
    length(D,LN),
    NTR is TR + LN,
    permutation_num(L,PL,D,NTR,R).

permutation_num([X|L],[Y|PL],D,TR,R) :-
    select(Y,D,ND),
    

even_permutation(L,L).

