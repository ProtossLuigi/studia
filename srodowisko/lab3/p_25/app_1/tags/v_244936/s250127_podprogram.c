#include "program.h"

void s250127_podprogram(){

	printf("Aleksander Skrzypek 250127\n");
	printf("Program wczytuje dwie liczby całkowite i zwraca sumę ich kwadratów\n");
	
	int a, b, sum;
	
	printf("a: ");
	scanf("%d", &a);
	printf("b: ");
	scanf("%d", &b);
	
	sum = a*a + b*b;
	printf("Suma kwadratów wynosi: %d \n", sum);

}
