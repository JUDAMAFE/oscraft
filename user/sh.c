#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "parser.h"
#include "commands.h"

// getcmd muestra el prompt "$ " en pantalla, y lee lo que el usuario  escribe usando gets(), guardandolo en buf. Si el usuario no escribio nada (por ejemplo, cerro la entrada con Ctrl+D), devuelve -1 para indicarle a main() que debe terminar.
int getcmd(char *buf, int nbuf)
{
  printf(2, "$ ");
  memset(buf, 0, nbuf);   
  gets(buf, nbuf);        // lee la linea escrita por el usuario
  if(buf[0] == 0) 
    return -1;
  return 0;
}

// main ciclo principal Lee un comando con getcmd(), Si el usuario escribio "exit", termina el shell, Si no, crea un proceso hijo que usa execline(), El proceso padre queda en Wait

int main(void)
{
  static char buf[100];  
  int pid;                // identificador del proceso hijo

  printf(1, "PROYECTO JUDAMA\n");

  while(getcmd(buf, sizeof(buf)) >= 0){

    //Revisa si el usuario escribio "exit" para terminar el shell, se revisa antes de empezar le hijo porque si no no terminaria la shel si no el hijo
    if(strcmp(buf, "exit\n") == 0 || strcmp(buf, "exit") == 0)
      exit();

    // Se crea el hijo con fork para que el padre pueda seguir ejecutando el shell al mismo tiempo, padre queda en wait
    pid = fork();
    if(pid == 0){
      // Corre solo el hijo, usa execline para ver si hay pipes y que comandos ejecutar, si no hay pipes solo ejecuta el comando que escribio el usuario
      execline(buf);
      exit();
    } else {
      // Wait del padre
      wait();
    }
  }
  exit();
}