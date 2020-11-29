#include "program.h"

void s244927_podprogram() 
{
    printf("Jacek Duszenko, nr indeksu: 244927\n");
    printf("Program wczytuje 5 liczb i wypisuje je posortowane rosnąco");  
    int nz [5];
    for (int i =0;i<5;++i) scanf("%d", &nz[i]); 
    
     for (int i = 1;i<5;++i) 
    {
       int val = nz[i];
       int prev = i-1;
       while (prev >= 0 && nz[prev] >= val)
       {
           nz[prev + 1] = nz[prev];
           --prev;
       }
       nz[prev+1] = val;
    }

    for (int i =0;i<5;++i) printf("%d ", nz[i]);
}