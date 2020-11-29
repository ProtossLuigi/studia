#include "program.h"

void s250346_podprogram()
{
  printf("Jakub Balicki 250346\n");
  printf("Program wcztuje jedna liczbe calkowita i drukuje jest szescian\n");
  
  int x;
  int wynik;

  printf("x: ");
  scanf("%d", &x);

  wynik = x*x*x;

  printf("Szescian liczby %d jest rowny %d\n", x, wynik);
}
