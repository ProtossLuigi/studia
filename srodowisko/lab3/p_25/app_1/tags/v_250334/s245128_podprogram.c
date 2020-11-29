#include "program.h"

void s245128_podprogram()
{

  printf("nr indeksu: 245128\n");
  printf("Program wczytuje liczbę całkowitą i drukuje sume jej cyfr\n");
  int x;
  printf("Podaj liczbę x: ");
  scanf("%d", &x);
  
  if(x < 0)
  	x = -x;
  
  int sum = 0;
  
  while(x > 0)
  {
  	sum += x%10;
  	x/=10;
  }

  printf("Suma cyfr w x wynosi: %d\n", sum);

}
