#include "program.h"

// szybka odwrotność pierwiastka kwadrawoego z quake iii
float Q_rsqrt( float number )
{
        long i;
        float x2, y;
        const float threehalfs = 1.5F;

        x2 = number * 0.5F;
        y  = number;
        i  = * ( long * ) &y;                       // evil floating point bit level hacking
        i  = 0x5f3759df - ( i >> 1 );               // what the heck?
        y  = * ( float * ) &i;
        y  = y * ( threehalfs - ( x2 * y * y ) );   // 1st iteration

        return y;
}


void s250345_podprogram()
{
printf("Jan Pawłowski, nr indeksu 250345\n");
printf("Program liczy szybką odwrotność pierwiastka kwadratowego\n");
float input;
printf("Podaj liczbę: ");
scanf("%f", &input);

printf("Szybka odwrotność pierwiastka kwadratowego to %f\n", Q_rsqrt(input));
}
