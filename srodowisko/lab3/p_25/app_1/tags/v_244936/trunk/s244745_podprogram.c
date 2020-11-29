#include "program.h"

void s244745_podprogram() {
    printf("Karolina Antonik, nr indeksu: 244745\n");
    printf("Program wczytuje liczbę naturalną i drukuje trojkat Pascala o tej wysokości\n");  
    int rows;

    printf("Podaj wysokosc trojkata Pascala: ");
	scanf("%d", &rows);
	int coef = 1, space, i, j;

    for (i = 0; i < rows; i++) {
      for (space = 1; space <= rows - i; space++)
         printf("  ");
      for (j = 0; j <= i; j++) {
         if (j == 0 || i == 0)
            coef = 1;
         else
            coef = coef * (i - j + 1) / j;
         printf("%4d", coef);
      }
      printf("\n");
   }
}
