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

// Ejecuta un comando  en el proceso actual.
// Se usa dentro de un hijo ya creado con fork(), para comandos sueltos y para cada lado de un pipe.
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

// Busca un '|' en la linea. Si lo encuentra, corta el string ahi mismo
// lo convierte en \0 y devuelve un puntero a lo que sigue despues.
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

int
main(void)
{
  static char buf[100];

  while(getcmd(buf, sizeof(buf)) >= 0){
    // caso especial: exit se revisa ANTES de separar por pipe,
    // sobre la linea completa tal cual la escribio el usuario.
    
    if(strcmp(buf, "exit\n") == 0 || strcmp(buf, "exit") == 0)
      exit();

    char *right = findpipe(buf);

    if(right == 0){
      // No hay pipe: comando simple, igual que antes.
      int pid = fork();
      if(pid == 0){
        runcmd(buf);
      } else {
        wait();
      }
    } else {
      // Hay pipe: buf tiene el comando izquierdo, right el derecho.
      int fd[2];
      pipe(fd);

      int pid1 = fork();
      if(pid1 == 0){
        // Hijo izquierdo: su salida va al pipe
        close(1);
        dup(fd[1]);
        close(fd[0]);
        close(fd[1]);
        runcmd(buf);
      }

      int pid2 = fork();
      if(pid2 == 0){
        // Hijo derecho: su entrada viene del pipe
        close(0);
        dup(fd[0]);
        close(fd[0]);
        close(fd[1]);
        runcmd(right);
      }

      // El padre cierra ambos extremos y espera a los dos hijos
      close(fd[0]);
      close(fd[1]);
      wait();
      wait();
    }
  }
  exit();
}