#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"
#include "parser.h"
#include "commands.h"


// runcmd se llama desde un hijo para ejectar un comando sin pipes pero puede tener redirecciones
void runcmd(char *cmdline)
{
  char *argv[MAXARGS];      // argumentos del comando
  char *infile, *outfile;   // nombre de archivo para redireccion (o NULL)
  int argc;                 // cantidad de argumentos

  // Separa el texto en palabras y busca redireccion
  argc = parseline(cmdline, argv, &infile, &outfile);

  // termina el proceso si el usuario envia enter sin nada 
  if(argc == 0)
    exit();

 
  // en cas ode redireccion de netrasa < cierra la entarda 0 y abre el archivo para leer desde ahi 
  if(infile){
    close(0);
    if(open(infile, O_RDONLY) < 0){
      printf(2, "cannot open %s\n", infile);
      exit();
    }
  }

  
  // si la redireccion es de salida, cieraa la entrada 1 y abre el archivo para exrivei, si la salida falla, corta el wait del padre para que se quede epsrando siempre 
  if(outfile){
    close(1);
    if(open(outfile, O_WRONLY | O_CREATE) < 0){
      printf(2, "cannot open %s\n", outfile);
      exit();
    }
  }

  // exec() cambia el codigo del proces opor el del argumento pedido, si no existe o falla termina con exit y avisa al padre
  exec(argv[0], argv);

  // fallo 
  printf(2, "exec %s failed\n", argv[0]);
  exit();
}


// execline resuelve las lineas con uno o mas pipes separando en izquiera y derecha, y vuelve a enviar el texto a la misma funcion para verificar si hay mas pipes y asi consecutivamente 

void execline(char *cmdline)
{
  char *right;       // lo que queda despues del primer pipe
  int fd[2];          // descriptores de pipe 0=lectura, 1=escritura
  int pid1, pid2;      // identificadores de los procesos hijos

  // Busca si hay un pipe 
  right = findpipe(cmdline);

  // si solo hay un pipe
  if(right == 0){
    runcmd(cmdline);
    return; 
             
  }

 
  // cdmline es la izquierda y right es lo que queda en el texto y los "tubos" se crean con un lado de lectura(0) y el otro de escirtura(1)
 
  pipe(fd);

  // el primer hijo realiza la izquierda y la salida stdout se usa para escribir en el pipe y no en la pamtalla
  pid1 = fork();
  if(pid1 == 0){
    close(1);       // cierra la salida de pantalla
    dup(fd[1]);      // duplica escreitura para que ocupe el sitio de lapantalla que ahora seria fd 1
    close(fd[0]);    // cierra lectura 
    close(fd[1]);    // cierra el original porque la informacion ya esta en fd 1
    runcmd(cmdline); // ejecuta el comando de la izquierda
  }

  
  // el segundo hijo ejecuta lo de la derecha, la entrada es stdin que viene de la copia anterios y se lee desde ahi
  pid2 = fork();
  if(pid2 == 0){
    close(0);        // cierra la entrada teclado
    dup(fd[0]);       // duplica la lectura para qje remplace al teclado y queda ndn fd 0
    close(fd[0]);     // se queda con la copia y cierra el principal
    close(fd[1]);     // cierra escritura

    // se usa la recurcion para auto llamar el comando y verificar que no haya mas pipes a a la derecha
    execline(right);
    exit(); // termina el proceso despues de todos los pipes
            
  }

  // El proceso padre (quien llamo a execline) no participa en la
  // ejecucion de los comandos: solo debe cerrar AMBOS extremos del
  // pipe (aunque no los use), porque si los deja abiertos, el sistema
  // operativo puede pensar que "alguien mas" todavia podria escribir
  // o leer, y el segundo comando se quedaria esperando datos para
  // siempre sin recibir nunca la señal de "no hay mas datos".
  // cierra los extremos del pipe "tubo" para que el padre no piende que alguien mas va a enviar o recivbir datos
  close(fd[0]);
  close(fd[1]);

  //  el padre espera a que ambos hijos terminen
  wait();
  wait();
}