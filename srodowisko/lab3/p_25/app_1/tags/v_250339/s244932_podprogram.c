#include "program.h"

void s244932_podprogram()
{
  printf("Krzysztof Szafraniak 244932\n");
  printf("Program wcztuje liczbe calkowita i drukuje liczbe o 1 mniejsza\n");
  
  int x;
  int wynik;

  printf("x: ");
  scanf("%d", &x);

  wynik = x-1;

  printf("Liczba o 1 mniejsza od %d to %d\n", x, wynik);
}
