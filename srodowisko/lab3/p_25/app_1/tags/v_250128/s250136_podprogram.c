#include "program.h"

int s250136_factorial(int n){
  if(n == 0)
    return 1;
  int ac = 1;
  for(int i = 2; i <= n; i++) {
    ac *= i;
  }
  return ac;
}

int s250136_binom(int n, int k){
  return s250136_factorial(n)/(s250136_factorial(n-k)*s250136_factorial(k));
}

void s250136_podprogram() {
  int n;
  int k;
  printf("Krzysztof Szymaniak 250136\n");
  printf("Program pobiera dwie liczby całkowite n i k oraz drukuje współczynnik dwumianowy n po k\n\n");
  printf("Podaj n: ");
  scanf("%d", &n);
  printf("Podaj k: ");
  scanf("%d", &k);
  if(n < 1 || k < 0){
    printf("Nieprawidłowe dane.\n");
    return;
  }
  if(n < k)
    printf("n jest większe od k.\n");
  else{
    printf("\n%d po %d wynosi %d\n", n, k, s250136_binom(n, k));
  }
}
