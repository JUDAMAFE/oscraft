#include "kernel/types.h"
#include "kernel/riscv.h"
#include "user/sysinfo.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  struct sysinfo info;

  if (sysinfo(&info) < 0) {
    fprintf(2, "%s: sysinfo failed\n", argv[0]);
    exit(1);
  }

  printf("--- SYSINFO REPORT ---\n");
  printf("Free memory (bytes): %d\n", (int)info.freemem);
  printf("Used pages: %d\n", (int)info.n_upages);
  printf("Available pages: %d\n", (int)info.n_apages);
  printf("Runnable processes: %d\n", (int)info.n_runnable);

  exit(0);
}