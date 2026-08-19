#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

#define MAXARGS 32

int
getcmd(char *buf, int nbuf)
{
  printf(2, "$ ");
  memset(buf, 0, nbuf);
  gets(buf, nbuf);
  if(buf[0] == 0) // EOF
    return -1;
  return 0;
}

// Separa buf en un arreglo de argumentos (argv)
int
parseline(char *buf, char **argv)
{
  int argc = 0;
  char *p = buf;

  while(*p){
    // saltar espacios
    while(*p == ' ' || *p == '\n')
      *p++ = 0;
    if(*p == 0)
      break;
    argv[argc++] = p;
    while(*p && *p != ' ' && *p != '\n')
      p++;
  }
  argv[argc] = 0;
  return argc;
}

int
main(void)
{
  static char buf[100];
  char *argv[MAXARGS];

  while(getcmd(buf, sizeof(buf)) >= 0){
    int argc = parseline(buf, argv);
    if(argc == 0)
      continue;

    // comando interno: exit
    if(strcmp(argv[0], "exit") == 0)
      exit();

    int pid = fork();
    if(pid == 0){
      // proceso hijo: ejecuta el comando
      exec(argv[0], argv);
      printf(2, "exec %s failed\n", argv[0]);
      exit();
    } else {
      // proceso padre: espera al hijo
      wait();
    }
  }
  exit();
}