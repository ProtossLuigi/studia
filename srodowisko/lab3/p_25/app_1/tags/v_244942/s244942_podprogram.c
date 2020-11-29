#include "program.h"

int f(int x){
	if(x == 0){
		return 1;
	} else{
		return x * f(x-1);
	}
}

void s244942_podprogram(){
	printf("Kajetan Bilski 244942\n");
	printf("Program wczytuje liczbę naturalną i drukuje jej silnię.\n");
	int x;
	scanf("%d", &x);
	if(x >= 0){
		printf("%d\n", f(x));
	}
}
