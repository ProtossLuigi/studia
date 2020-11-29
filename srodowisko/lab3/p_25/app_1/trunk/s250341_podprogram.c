#include "program.h"

void s250341_podprogram()
{
  printf("Szymon Kazimierczak, nr indeksu: 250341\n");
  printf("Program wczytuje dwie liczby calkowite i drukuje ich iloczyn\n");

  int a;
  printf("Podaj liczbe: "); 
  scanf("%d", &a); 
  
  int b;
  printf("Podaj liczbe: "); 
  scanf("%d", &b);
  
  printf("Iloczyn liczb %d i %d wynosi %d\n", a, b, a*b); 
}
