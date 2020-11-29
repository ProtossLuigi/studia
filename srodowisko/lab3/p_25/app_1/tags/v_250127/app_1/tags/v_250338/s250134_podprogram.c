#include "program.h"

void s250134_podprogram()
{
  printf("Patryk Majewski, nr indeksu: 250134\n");
  printf("Program wczytuje liczbę całkowitą i sprawdza, czy jest parzysta.\n");
  
  int a;
  printf("Podaj liczbę: ");
  scanf("%d", &a);
  
  if (a % 2 == 0)
    printf("Liczba jest parzysta.\n");
  else
    printf("Liczba nie jest parzysta.\n");
}
