#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc < 2){
    fprintf(2, "uso: trace <nombre_syscall>\n");
    exit(1);
  }

  if(trace(argv[1]) < 0){
    fprintf(2, "trace: no se pudo monitorear %s\n", argv[1]);
    exit(1);
  }

  printf("Monitoreo activado para: %s\n", argv[1]);
  printf("PID actual: %d\n", getpid());

  int pid = getpid();
  kill(pid);
  uptime();

  exit(0);
}
