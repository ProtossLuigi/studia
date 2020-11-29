#include "program.h"

void s244936_podprogram() {
  printf("Konrad Grochowski 244936\n");
  printf("Program dlugosc boku kwadratu i podaje jego pole\n");
  
  int length;
  int result;

  printf("length: \n");
  scanf("%d", &length);

  result = length*length;

  printf("\nPole tego  kwadratu wynosi %d\n", result);
}
