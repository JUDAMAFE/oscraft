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
    // saltar espacios
    while(*p == ' ' || *p == '\n')
      *p++ = 0;
    if(*p == 0)
      break;

    // redireccion de entrada: < archivo
    if(*p == '<'){
      *p++ = 0;
      while(*p == ' ')
        p++;
      *infile = p;
      while(*p && *p != ' ' && *p != '\n')
        p++;
      continue;
    }

    // redireccion de salida: > archivo
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
// Ciclo que se repite hasta que el usuario cierre el programa, lee el comando, lo separa en palabras y ejecuta el comando en un proceso hijo, mientras que el proceso padre espera a que termine el hijo.

int
main(void)
{
  static char buf[100];
  char *argv[MAXARGS];
  char *infile, *outfile;

  while(getcmd(buf, sizeof(buf)) >= 0){
    int argc = parseline(buf, argv, &infile, &outfile);
    if(argc == 0)
      continue;

    // comando interno: exit
    if(strcmp(argv[0], "exit") == 0)
      exit();

    int pid = fork();
    if(pid == 0){
      // proceso hijo: primero aplica redirecciones, luego ejecuta el comando

      // redireccion de entrada: cierra fd 0 y abre el archivo en su lugar
      if(infile){
        close(0);
        if(open(infile, O_RDONLY) < 0){
          printf(2, "cannot open %s\n", infile);
          exit();
        }
      }

      // redireccion de salida: cierra fd 1 y abre/crea el archivo en su lugar
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
    } else {
      // proceso padre: espera al hijo
      wait();
    }
  }
  exit();
}