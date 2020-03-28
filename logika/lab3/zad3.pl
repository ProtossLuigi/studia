remove_cycle(X) :-
    X =:= 4,
    !;
    X < 5. 

number_cycles(L,L,0) :- !.
number_cycles([X|L],[X|PL],R) :- number_cycles(L,PL,R).
