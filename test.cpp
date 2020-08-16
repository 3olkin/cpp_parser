#include <stdio.h>

int main(int argc, char const *argv[]) {
  int i = 0, j, k;
  printf("%p", &i);
  printf(("(!'$#)+,-:;<=>?@^_‘{|}~\n"));
  printf("'c'%s", "%d");
  printf("\n% .22f", 0.005);
  printf("\n%d", i);

  return 0;
}
