# include "program.h"


int fib(int i){
	if(i == 0) return 0;
	if(i == 1) return 1;
	return fib(i-1) + fib(i-2);
}

void s244748_podprogram()
{
	printf("Michał Fujarewicz 244748\n");
	printf("Program wczytuje nieujemną liczbe calkowita n i zwraca n-tą liczbę fibonnaciego.\nPodaj liczbę całkowitą: ");

	int x;
	
	scanf("%d", &x);

	printf("FIB(%d) = %d\n", x, fib(x));
}
