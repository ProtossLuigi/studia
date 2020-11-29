#include "program.h"

void s250342_podprogram()
{

  printf("Student Agata Babiarz nr indeksu: 250342\n");
  printf("Program wczytuje liczbę całkowitą i drukuje dla niej wróżbę\n");
  int x;
  printf("Podaj liczbę x: ");
  scanf("%d", &x);
  if(x%2)
  {
    printf("Na Twojej najbliższej drodze życiowej czeka cię sukces w pracy i życiu rodzinnym.");
  }
  else
  {
    printf("Po kilku niepowodzeniach osiągniesz sukces w ważnych dziedzinach życia.");
  }

}
