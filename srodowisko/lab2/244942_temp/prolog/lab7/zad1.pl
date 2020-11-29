merge(X,Y,Z):-
    freeze(X,(
        X = [],
        freeze(Y,Y=Z)
        )).
merge(X,Y,Z):-
    freeze(Y,(
        Y = [],
        freeze(X,X=Z)
        )).
merge([X|Xs],[Y|Ys],R):-
    freeze(X,
        freeze(Y,(
            X > Y -> (
                R = [Y|L],
                merge([X|Xs],Ys,L)
                );
                R = [X|L],
                merge(Xs,[Y|Ys],L)
            ))
        ).