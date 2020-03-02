mezczyzna(a).
ojciec(a,b).
ojciec(a,c).
kobieta(b).
mezczyzna(c).
matka(d,b).
matka(d,c).
kobieta(d).
mezczyzna(e).
ojciec(e,d).
rodzic(X,Y) :-
    ojciec(X,Y);
    matka(X,Y).


jest_matka(X) :-
    matka(X,Y).
jest_ojcem(X) :-
    ojciec(X,Y).
jest_synem(X) :-
    mezczyzna(X),
    rodzic(Y,X).
siostra(X,Y) :-
    kobieta(X),
    X \= Y,
    rodzic(Z,X),
    rodzic(Z,Y).
dziadek(X,Y) :-
    ojciec(X,Z),
    rodzic(Z,Y).
rodzenstwo(X,Y) :-
    X \= Y,
    rodzic(Z,X),
    rodzic(Z,Y).