#include "program.h"

void s250135_podprogram()
{
  printf("Kamil Matejuk, nr indeksu: 250135\n");
  printf("Program wczytuje liczbe calkowita i sprawdza czy jest ona dodatnia czy ujemna\n");

  int A;
  printf("Podaj liczbe: "); 
  scanf("%d", &A); 
  
  if (A > 0) 
    printf("Liczba %d jest dodatnia\n", A); 
  else if (A < 0) 
    printf("Liczba %d jest ujemna\n", A); 
  else if (A == 0) 
    printf("%d jest równe zero\n", A); 
}