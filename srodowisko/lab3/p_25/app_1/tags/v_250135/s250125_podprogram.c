#include "program.h"

void s250125_podprogram()
{
  printf("Piotr Szymański 250125\n");
  printf("Program wcztuje dwie liczby calkowite x,y i drukuje ich iloczyn\n");
  
  int x, y;
  int i;

  printf("x: ");
  scanf("%d", &x);
  printf("y: ");
  scanf("%d", &y);

  i = x*y;

  printf("Iloczyn liczb %d %d wynosi %d\n", x, y, i);
}