#include "program.h"

void s250339_podprogram()
{
  printf("Konrad Bratek, nr indeksu: 250339\n");
  printf("Program wczytuje liczbe calkowita i drukuje jej reszte dzielenia przez 3\n");

  int liczba;
  printf("Podaj liczbe: ");
  scanf("%d", &liczba);
  printf("Reszta %d z dzielenia przez 3 to %d\n", liczba, liczba % 3);
}
