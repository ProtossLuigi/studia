# include "program.h"

void s250347_podprogram()
{
	printf("Lukasz Kepka 250347\n");
	printf("Program wczytuje liczbe calkowita i zwraca jej sasiednie liczby.");

	int x;
	
	scanf("%d", &x);

	printf("%d, %d, %d", x-1, x, x+1);
}
