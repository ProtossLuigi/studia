reeeee(X,[X|L],L).
reeeee(X,[Y|L],L2) :- Y \= X, L2 = [Y|L3], reeeee(X,L,L3).

partial_list(0,[],[],[]).
partial_list(N,[N|L1],[N|L2],L3) :- N > 0, M is N-1, partial_list(M,L1,L3,L2).
partial_list(N,[X|L1],L2,L3) :-
    N > 0,
    between(1,N,X),
    \+ member(X,L2),
    \+ member(X,L3),
    sort(0,@>,[X|L3],L4),
    partial_list(N,L1,L4,L2).

lista(N,L) :- N >= 0, partial_list(N,L2,[],[]), reverse(L,L2).