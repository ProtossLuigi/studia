my_write(ID, LM, MSG) :-
    mutex_lock(LM),
    tab(ID),
    write("["),
    write(ID),
    write("] "),
    write(MSG),
    write(.),
    nl,
    mutex_unlock(LM).

loop(ID, LM, L, R) :-
    my_write(ID, LM, "mysli"),
    my_write(ID, LM, "chce prawy widelec"),
    mutex_lock(R),
    my_write(ID, LM, "podnosi prawy widelec"),
    my_write(ID, LM, "chce lewy widelec"),
    mutex_lock(L),
    my_write(ID, LM, "podnosi lewy widelec"),
    my_write(ID, LM, "je"),
    my_write(ID, LM, "odlkada prawy widelec"),
    mutex_unlock(R),
    my_write(ID, LM, "odklada lewy widelec"),
    mutex_unlock(L),
    loop(ID, LM, R, L).

filozofowie() :-
    mutex_create(LM),
    mutex_create(F1),
    mutex_create(F2),
    mutex_create(F3),
    mutex_create(F4),
    mutex_create(F5),
    thread_create(loop(1, LM, F1, F2), _),
    thread_create(loop(2, LM, F2, F3), _),
    thread_create(loop(3, LM, F3, F4), _),
    thread_create(loop(4, LM, F4, F5), _),
    thread_create(loop(5, LM, F5, F1), _).