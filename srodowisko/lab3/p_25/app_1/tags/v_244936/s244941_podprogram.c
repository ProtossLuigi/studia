#include "program.h"
void s244941_podprogram(){
	char in[256];
       	printf("Pawel Dychus 244941\nProgram wczytuje napis i drukuje go na zielono\n");
	scanf("%s", in);
	printf("\x1B[32m%s\n\x1B[0m", in);
}
