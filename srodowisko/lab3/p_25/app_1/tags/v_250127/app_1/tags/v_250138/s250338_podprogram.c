#include "program.h"

void s250338_podprogram()
{
    printf("Dominik Frankowski 250338\n");
    printf("Program wczytuje liczbe calkowita i drukuje jej szescian pomnozony przez 2\n");

    int x, y;

    printf("x: ");
    scanf("%d", &x);
    y = x * x * x * 2;
    printf("Szescian liczby %d pomnozony przez 2: %d\n", x, y);
}
