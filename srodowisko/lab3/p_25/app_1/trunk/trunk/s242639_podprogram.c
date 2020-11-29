#include "program.h"

#include <unistd.h>

void s242639_podprogram()
{
  printf("Paweł Ostrowski 242639\n");
  printf("Program wczytuje liczbę całkowitą, zupełnie ją ignoruje i wypisuje liczbę 1\n");

  int liczba;
  printf("Podaj liczbę: ");
  scanf("%d", &liczba);
  printf("Myślę...\n");
  sleep(2);
  printf("1\n");
}
