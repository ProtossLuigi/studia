#include "program.h"

void s250332_podprogram()
{
  printf("Damian Balinski 250332\n");
  printf("Program wcztuje dwie liczby calkowite i drukuje ich srednia arytmetyczna\n");
  
  int x, y;
  float s;

  printf("x: ");
  scanf("%d", &x);
  printf("y: ");
  scanf("%d", &y);

  s = x + (y - (float)x)/2;

  printf("Srednia arytmetyczna liczb %d %d wynosi %f\n", x, y, s);
}
