#include "program.h"

void s243434_podprogram()
{
  printf("Karol Szymończyk 243434\n");
  printf("Program wczytuje liczbę całkowitą i drukuje jej cyfrę jedności\n");

  int liczba;
  printf("Podaj liczbę: ");
  scanf("%d", &liczba);
  printf("Cyfra jedności liczby %d to %d\n", liczba, abs(liczba % 10));
}
