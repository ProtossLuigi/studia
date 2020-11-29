#include "program.h"

void s250335_podprogram()
{
	printf("Mateusz Walejko 250335\n");
	printf("Program wczytuje liczbe naturalna i drukuje choinke o tej wysokosci\n");

	int h;

	printf("Podaj wysokosc choinki: ");
	scanf("%d", &h);
	h--;
	printf("\n");

	for (int i = 0; i < h; i++) {
		for (int j = 0; j < h - i - 1; j++) {
			printf(" ");
		}
		for (int j = 0; j < 2*i + 1; j++) {
			printf("*");
		}
		printf("\n");
	}
	
	for (int j = 0; j < h - 1; j++) {
		printf(" ");
	}
	printf("*\n");
}
