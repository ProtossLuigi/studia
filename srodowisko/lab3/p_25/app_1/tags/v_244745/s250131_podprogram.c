#include "program.h"

void s250131_podprogram()
{

  printf("Wiktoria Byra, nr indeksu: 250131\n");
  printf("Program wczytuje imię i życzy miłego dnia\n");
  char name[20];
  
  printf("Jak masz na imię?: ");
  scanf("%s", &name);
 	
  printf("Miłego dnia %s!\n", name);
  return 0;
}
