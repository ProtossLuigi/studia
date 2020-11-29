left_of(L,R,T) :- append(_,[L,R|_],T).
next_to(X,Y,L) :- left_of(X,Y,L); left_of(Y,X,L).
rybki(X) :-
    Houses = [H1,_,H3,_,_],
    H1 = (_,norwegian,_,_,_),
    member((red,englishman,_,_,_), Houses),
    left_of((green,_,_,_,_),(white,_,_,_,_),Houses),
    member((_,dutchman,_,tea,_),Houses),
    next_to((_,_,_,_,light),(_,_,cats,_,_),Houses),
    member((yellow,_,_,_,cigars),Houses),
    member((_,german,_,_,pipe),Houses),
    H3 = (_,_,_,milk,_),
    next_to((_,_,_,_,light),(_,_,_,water,_),Houses),
    member((_,_,birds,_,no_filter),Houses),
    member((_,swede,dogs,_,_),Houses),
    next_to((_,norwegian,_,_,_),(blue,_,_,_,_),Houses),
    next_to((_,_,horses,_,_),(yellow,_,_,_,_),Houses),
    member((_,_,_,beer,mentol),Houses),
    member((green,_,_,coffee,_),Houses),
    member((_,X,fishes,_,_),Houses),
    !.