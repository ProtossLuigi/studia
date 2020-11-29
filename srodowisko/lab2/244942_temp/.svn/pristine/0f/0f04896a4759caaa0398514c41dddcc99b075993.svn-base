jednokrotnie(X,L) :- L = [X|Tail], \+ member(X,Tail).
jednokrotnie(X,L) :- L = [Y|Tail], jednokrotnie(X,Tail), X \= Y.
dwukrotnie(X,L) :- L = [X|Tail], jednokrotnie(X,Tail).
dwukrotnie(X,L) :- L = [Y|Tail], dwukrotnie(X,Tail), X \= Y.