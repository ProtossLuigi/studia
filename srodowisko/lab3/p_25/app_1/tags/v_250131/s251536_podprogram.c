#include "program.h"
#include <time.h>
#include <stdlib.h>

void s251536_podprogram()
{
  printf("Andrei Shpakouski 251536\n");
  printf("Program utworzy dwie liczby losowe a i b, potem oblicza obwód oraz pole prostokąta\n");
  
  int a;
  int b;
  
  srand(time(NULL));
  a = rand() % 50;
  b = rand() % 50;
  
  printf("a = %d\n", a);
  printf("b = %d\n", b);
  printf("perimeter = %d\n", ((a + b) * 2));
  printf("area = %d\n", (a*b));
}
