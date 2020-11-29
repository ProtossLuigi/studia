#include "program.h"

void  s250349_podprogram() {
    int n, i;

    unsigned long long fact = 1;
    printf("Wojciech Wróblewski , nr indeksu 250349 \n");
    printf("Program pobiera liczbę naturalną n i zwraca wynik n! (silnia od n) \n");
    printf("Podaj liczbę naturalną: \n");
    scanf("%d", &n);

    if (n < 0)
        printf("error, podaj liczbę naturalną");
    else {
        for (i = 1; i <= n; ++i) {
            fact *= i;
        }
        printf("Silnia z %d to  %llu", n, fact);
    }

}

