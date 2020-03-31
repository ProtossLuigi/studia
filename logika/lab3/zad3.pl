find_and_replace(X,[Y|L1],[X|_],Y,[X|L1]) :- !.
find_and_replace(X,[Y|L1],[_|L2],Z,[Y|L3]) :-
    find_and_replace(X,L1,L2,Z,L3).

number_inversions(L,L,0) :- !.
number_inversions([X|L],[X|PL],R) :- number_inversions(L,PL,R), !.
number_inversions([X|L],PL,R) :-
    find_and_replace(X,[X|L],PL,Y,[X|TL]),
    number_inversions([Y|TL],PL,RR),
    R is RR + 1.

odd_permutation(L,PL) :-
    permutation(L,PL),
    number_inversions(L,PL,R),
    R mod 2 =:= 1.

even_permutation(L,PL) :-
    permutation(L,PL),
    number_inversions(L,PL,R),
    R mod 2 =:= 0.