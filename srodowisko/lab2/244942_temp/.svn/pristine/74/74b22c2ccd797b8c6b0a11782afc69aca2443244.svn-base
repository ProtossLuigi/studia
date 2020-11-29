s1 --> sym1(Sem, a), sym1(Sem, b).
sym1(e, _) --> [].
sym1(s(Sem), S) --> [S], sym1(Sem, S).

s2 --> sym2(Sem, a), sym2(Sem, b), sym2(Sem, c).
sym2(e, _) --> [].
sym2(s(Sem), S) --> [S], sym2(Sem, S).

s3 --> sym1(Sem, a), sym3(Sem, b).
sym3(e, _) --> [].
sym3(s(e), S) --> [S].
sym3(s(s(Sem)), S) --> sym3(s(Sem), S), sym3(Sem, S).

p([]) --> [].
p([X | Xs]) --> [X], p(Xs).
