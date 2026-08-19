#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

#define MAXARGS 32

// Lee lo que escribe el usuario y lo guarda en buf, imprime $ y si el usuario cerro usa -1 para cerrar
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

// Separar el string en palabras convirtiendo los espacios en \0 para poder entender el comando (argv)
// Ademas detecta los simbolos < y > para redireccion, guardando el nombre
// del archivo en infile/outfile sin meterlos en argv.
int
parseline(char *buf, char **argv, char **infile, char **outfile)
{
  int argc = 0;
  char *p = buf;
  *infile = 0;
  *outfile = 0;

  while(*p){
    while(*p == ' ' || *p == '\n')
      *p++ = 0;
    if(*p == 0)
      break;

    if(*p == '<'){
      *p++ = 0;
      while(*p == ' ')
        p++;
      *infile = p;
      while(*p && *p != ' ' && *p != '\n')
        p++;
      continue;
    }

    if(*p == '>'){
      *p++ = 0;
      while(*p == ' ')
        p++;
      *outfile = p;
      while(*p && *p != ' ' && *p != '\n')
        p++;
      continue;
    }

    argv[argc++] = p;
    while(*p && *p != ' ' && *p != '\n' && *p != '<' && *p != '>')
      p++;
  }
  argv[argc] = 0;
  return argc;
}

// Ejecuta un comando simple (con posible redireccion) en el proceso actual.
// Nunca regresa: o hace exec() con exito, o termina el proceso con exit().
void
runcmd(char *cmdline)
{
  char *argv[MAXARGS];
  char *infile, *outfile;
  int argc = parseline(cmdline, argv, &infile, &outfile);

  if(argc == 0)
    exit();

  if(infile){
    close(0);
    if(open(infile, O_RDONLY) < 0){
      printf(2, "cannot open %s\n", infile);
      exit();
    }
  }

  if(outfile){
    close(1);
    if(open(outfile, O_WRONLY | O_CREATE) < 0){
      printf(2, "cannot open %s\n", outfile);
      exit();
    }
  }

  exec(argv[0], argv);
  printf(2, "exec %s failed\n", argv[0]);
  exit();
}

// Busca el PRIMER '|' en la linea. Si lo encuentra, corta el string ahi
// mismo (lo convierte en \0) y devuelve un puntero a lo que sigue despues.
// Si no hay pipe, devuelve 0.
char *
findpipe(char *cmdline)
{
  char *p = cmdline;
  while(*p){
    if(*p == '|'){
      *p = 0;
      return p + 1;
    }
    p++;
  }
  return 0;
}

// Resuelve una linea que puede tener 0 o mas pipes encadenados.
// Si no hay pipe, ejecuta el comando directamente (no regresa).
// Si hay pipe, crea el pipe, un hijo para el lado izquierdo (runcmd) y
// otro para el lado derecho, que se resuelve llamando a execline otra vez
// (recursion), permitiendo cualquier cantidad de pipes encadenados.
void
execline(char *cmdline)
{
  char *right = findpipe(cmdline);

  if(right == 0){
    runcmd(cmdline);
    return; // runcmd nunca regresa realmente, pero lo dejamos por claridad
  }

  int fd[2];
  pipe(fd);

  int pid1 = fork();
  if(pid1 == 0){
    close(1);
    dup(fd[1]);
    close(fd[0]);
    close(fd[1]);
    runcmd(cmdline);
  }

  int pid2 = fork();
  if(pid2 == 0){
    close(0);
    dup(fd[0]);
    close(fd[0]);
    close(fd[1]);
    execline(right);
    exit();
  }

  close(fd[0]);
  close(fd[1]);
  wait();
  wait();
}

// Ciclo que se repite hasta que el usuario cierre el programa: lee el
// comando, revisa si es "exit", y si no, delega toda la ejecucion
// (con o sin pipes) a execline dentro de un proceso hijo.
int
main(void)
{
  static char buf[100];

  while(getcmd(buf, sizeof(buf)) >= 0){
    if(strcmp(buf, "exit\n") == 0 || strcmp(buf, "exit") == 0)
      exit();

    int pid = fork();
    if(pid == 0){
      execline(buf);
      exit();
    } else {
      wait();
    }
  }
  exit();
}