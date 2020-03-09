regula(X,+,Y,Y) :- number(X), X=:=0,!.
regula(X,+,Y,X) :- number(Y), Y=:=0,!.

regula(X,-,Y,X) :- number(Y), Y=:=0,!.
regula(X,-,X,0).

regula(X,*,_,0) :- number(X), X=:=0,!.
regula(_,*,X,0) :- number(X), X=:=0,!.
regula(X,*,Y,Y) :- number(X), X=:=1,!.
regula(X,*,Y,X) :- number(Y), Y=:=1,!.

regula(X,/,Y,X) :- number(Y), Y=:=1,!.
regula(X,/,X,1).
regula(X,/,_,0) :- number(X), X=:=0,!.
regula(X,/,Y,R) :- X = R * Y ; X = Y * R.

uproscz(W1+W2,O) :- uproscz(W1,X1), uproscz(W2,X2), regula(X1,+,X2,O).
uproscz(W1-W2,O) :- uproscz(W1,X1), uproscz(W2,X2), regula(X1,-,X2,O).
uproscz(W1*W2,O) :- uproscz(W1,X1), uproscz(W2,X2), regula(X1,*,X2,O).
uproscz(W1/W2,O) :- uproscz(W1,X1), uproscz(W2,X2), regula(X1,/,X2,O).
uproscz(O,O).

% uproscz(W,R) :-
%     W = W1 + W2, uproscz(W1,X1), uproscz(W2,X2), regula(X1,+,X2,R);
%     W = W1 - W2, uproscz(W1,X1), uproscz(W2,X2), regula(X1,-,X2,R);
%     W = W1 * W2, uproscz(W1,X1), uproscz(W2,X2), regula(X1,*,X2,R);
%     W = W1 / W2, uproscz(W1,X1), uproscz(W2,X2), regula(X1,/,X2,R);
%     W = R.

uprosc(W,R) :- uproscz(W,R),!.