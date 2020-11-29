#include "program.h"

void s250337_podprogram()
{
  printf("Paulina Gryszczyk, nr indeksu: 250337\n");
  printf("Program wczytuje liczbę całkowitą i wyświetla liczbę do niej przeciwną.\n");
  
  int a, b;
  printf("Podaj liczbę: ");
  scanf("%d", &a);
  
  b = a * (-1);
  
  printf("Liczba przeciwna: %d\n", b);
}
