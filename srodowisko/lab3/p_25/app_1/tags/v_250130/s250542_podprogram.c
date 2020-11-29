#include "program.h"

void s250542_podprogram()
{
	printf("Yauheni Tsyrkunovich 250542\n");
	printf("Program wczytuje liczbe calkowita i zwraca jej modulo 250542\n");
	
	int input;
	scanf("%d", &input);
	printf("%d mod 250542 = %d\n", input, input%250542);
}
