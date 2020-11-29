sqr(_,0,[]).
sqr(b,1,[1,2,3,4,7,11,14,18,21,22,23,24]).
sqr(m,1,[1,2,4,6,11,13,15,16]).
sqr(m,1,[2,3,5,7,12,14,16,17]).
sqr(m,1,[8,9,11,13,18,20,22,23]).
sqr(m,1,[9,10,12,14,19,21,23,24]).
sqr(s,1,[1,4,5,8]).
sqr(s,1,[2,5,6,9]).
sqr(s,1,[3,6,7,10]).
sqr(s,1,[8,11,12,15]).
sqr(s,1,[9,12,13,16]).
sqr(s,1,[10,13,14,17]).
sqr(s,1,[15,18,19,22]).
sqr(s,1,[16,19,20,23]).
sqr(s,1,[17,20,21,24]).

sqr(S,N,L) :-
    N > 1,
    NN is N-1,
    sqr(S,NN,L1),
    sqr(S,1,L2),
    last(L1,Last1),
    last(L2,Last2),
    Last1 < Last2,
    union(L1,L2,L).

write_cond(L,N,S) :-
    member(N,L),
    write(S),
    !;
    atom_length(S,Len),
    tab(Len).

draw_row_h(L,N1,N2,N3) :-
    write("+"),
    write_cond(L,N1,"---"),
    write("+"),
    write_cond(L,N2,"---"),
    write("+"),
    write_cond(L,N3,"---"),
    write("+"),
    nl.

draw_row_v(L,N1,N2,N3,N4) :-
    write_cond(L,N1,"|"),
    tab(3),
    write_cond(L,N2,"|"),
    tab(3),
    write_cond(L,N3,"|"),
    tab(3),
    write_cond(L,N4,"|"),
    nl.

draw_sqr(L) :-
    write("Rozwiazanie:\n"),
    draw_row_h(L,1,2,3),
    draw_row_v(L,4,5,6,7),
    draw_row_h(L,8,9,10),
    draw_row_v(L,11,12,13,14),
    draw_row_h(L,15,16,17),
    draw_row_v(L,18,19,20,21),
    draw_row_h(L,22,23,24).

solve(N,B,M,S) :-
    sqr(b,B,LB),
    sqr(m,M,LM),
    sqr(s,S,LS),
    union(LB,LM,Lp),
    union(Lp,LS,L),
    length(L,Len),
    N is 24 - Len,
    draw_sqr(L).

get_args(N,(duze(K)),_,M,S) :- solve(N,K,M,S).
get_args(N,(srednie(K)),B,_,S) :- solve(N,B,K,S).
get_args(N,(male(K)),B,M,_) :- solve(N,B,M,K).
get_args(N,(duze(K),Terms),_,M,S) :- get_args(N,(Terms),K,M,S).
get_args(N,(srednie(K),Terms),B,_,S) :- get_args(N,(Terms),B,K,S).
get_args(N,(male(K),Terms),B,M,_) :- get_args(N,(Terms),B,M,K).

zapalki(N,T) :- get_args(N,T,0,0,0).