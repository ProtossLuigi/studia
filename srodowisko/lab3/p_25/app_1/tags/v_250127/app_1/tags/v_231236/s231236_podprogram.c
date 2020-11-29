#include "program.h"

void s231236_podprogram()
{

  printf("Mateusz Bartnik, nr indeksu: 231236\n");
  printf("Program wczytuje trzy liczby całkowite i drukuje największą z nich\n");
  int x1, x2, x3;
  
  printf("Podaj liczbę x1: ");
  scanf("%d", &x1);
  
  printf("Podaj liczbę x2: ");
  scanf("%d", &x2);
  
  printf("Podaj liczbę x3: ");
  scanf("%d", &x3);

  int max = x1;
  
  if (max < x2) {max = x2;}
  if (max < x3) {max = x3;}
 	
  printf("Największa z liczb to: %d\n", max);

}
