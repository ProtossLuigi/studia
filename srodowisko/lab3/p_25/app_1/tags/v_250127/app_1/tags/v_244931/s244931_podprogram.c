#include "program.h"

void s244931_podprogram() 
{
    int x, y;
    printf("Student Piotr Andrzejewski, nr indeksu: 244931\n");
    printf("Program wczytuje dwie liczby naturalne i oblicza ich najmniejszy wspólny dzielnik\n");
    printf("Podaj pierwszą liczbę:\n");
    scanf("%d", &x);
    printf("Podaj drugą liczbę:\n");
    scanf("%d", &y);
    
    int a = x;
    int b = y;
    int tmp;
    while (b > 0) {
        tmp = a % b;
        a = b;
        b = tmp;
    }
    printf("NWD(%d, %d) = %d\n", x, y, a);
    
}
