#include "program.h"

void s250130_podprogram(){
    printf("Krzysztof Kądzioła, numer indeksu: 250130\n");
    printf("Program wczytuje liczbę całkowitą i "\
            "drukuje jej cyfrę dziesiątek\n\n");

    int i;

    printf("Podaj liczbę: ");
    scanf("%d", &i);

    i /= 10;

    printf("Cyfra dziesiątek: %d\n", i%10);
}
