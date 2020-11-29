#include "program.h"

void s250334_podprogram()
{

  printf("Nr indeksu: 250334\n");
  printf("Program wczytuje trzy liczby całkowite i sprawdza czy suma dwoch pierwszych jest rowna trzeciej\n");
  int a;
  int b;
  int c;
  printf("Podaj liczbe a: ");
  scanf("%d", &a);
  printf("Podaj liczbe b: ");
  scanf("%d", &b);
  printf("Podaj liczbe c: ");
  scanf("%d", &c);
  
  if((a + b) == c)
  	printf("TAK");
  else
  	printf("NIE");
  
}
