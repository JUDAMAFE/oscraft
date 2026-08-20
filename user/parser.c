#include "types.h"
#include "user.h"
#include "parser.h"


// parseline separa las palabras  y laa guarda en argv(punteros) para el exec y entiende que si hay flechas <> es para redireccionar la entrada o salida a un archivo 


// echo hola > salida.txt
//   argv = ["echo", "hola", NULL]
//   outfile = "salida.txt"
int parseline(char *buf, char **argv, char **infile, char **outfile)
{
  int argc;   // cantidad de palabras encontradas
  char *p;    // recorre el texto letra por letra

  argc = 0;
  p = buf;
  *infile = 0;   // si no hay redireccion de E
  *outfile = 0;  // si no hay redireccion de S

  // Recorre el texto hasta terminar
  while(*p){

    // Salta espacios y saltos de linea y los convierte en \0
    
    while(*p == ' ' || *p == '\n')
      *p++ = 0;
    if(*p == 0)
      break;

    // Si encuentra la felcha < lo que sigue es el archivo de entrada.
    if(*p == '<'){
      *p++ = 0;              // corta el texto justo en el <
      while(*p == ' ')       // salta espacios extra despues de <
        p++;
      *infile = p;           // guarda donde empieza el nombre del archivo
      while(*p && *p != ' ' && *p != '\n')
        p++;                 // avanza hasta el final de la palabra
      continue;               
    }

    // Si encuentra una flecha > lo que sigue es el archivo de salida.
    
    if(*p == '>'){
      *p++ = 0;
      while(*p == ' ')
        p++;
      *outfile = p;
      while(*p && *p != ' ' && *p != '\n')
        p++;
      continue;
    }

    // si es una palbra normal la recorre hasta el final
    argv[argc++] = p;
    while(*p && *p != ' ' && *p != '\n' && *p != '<' && *p != '>')
      p++;
  }

  // los textos siempre terminan con NULL
  argv[argc] = 0;
  return argc;
}

// findpipe busca el primer pipe con | y separa el texto ahi 
char *findpipe(char *cmdline)
{
  char *p;

  p = cmdline;

  while(*p){
    if(*p == '|'){
      *p = 0;       // corta el texto 
                    
      return p + 1;  // devuelve a la parte derecha
    }
    p++;
  }
  return 0;  // si no hay pipes
}