prime(LO,HI,N) :-
    between(LO,HI,N),
    N \= 1,
    \+ (
            between(2,N,X),
            X \= N,
            0 is N mod X
        ).