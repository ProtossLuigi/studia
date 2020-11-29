#include "program.h"

void s227537_podprogram()
{
	printf("Kamil Zakrzewski 227537\n");
	printf("Program wczytuje liczbe(rok) i sprawdza czy jest to rok przestepny\n");
  
	int y;

    printf("Wpisz rok: ");
    scanf("%d",&y);

    if(y % 4 == 0)
    {
    	//Nested if else
        if( y % 100 == 0)
        {
            if ( y % 400 == 0)
                printf("%d jest przestepny", y);
            else
                printf("%d nie jest przestepny", y);
        }
        else
            printf("%d jest przestepny", y );
    }
    else
        printf("%d nie jest przestepny", y);

}