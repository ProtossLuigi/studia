split_(IN,[],[],_):-
    freeze(IN,IN=[]).
split_([X|IN],OUT1,OUT2,odd):-
    freeze(X,(
        split_(IN,NOUT,OUT2,even),
        OUT1 = [X|NOUT]
        )).
split_([X|IN],OUT1,OUT2,even):-
    freeze(X,(
        split_(IN,OUT1,NOUT,odd),
        OUT2 = [X|NOUT]
        )).
split(IN,OUT1,OUT2):-
    split_(IN,OUT1,OUT2,odd).
:- [zad1].
merge_sort(X,Y):-
    freeze(X,(
        (
            X = [];
            X = [_]
            ),
        Y = X
        )).
merge_sort([X1,X2|Xs],Y):-
    freeze(X1,freeze(X2,(
        X = [X1,X2|Xs],
        split(X,S1,S2),
        merge_sort(S1,R1),
        merge_sort(S2,R2),
        merge(R1,R2,Y)
        ))).