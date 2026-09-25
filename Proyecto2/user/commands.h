#ifndef COMMANDS_H
#define COMMANDS_H

// Comando con redirecciones de entrada y salida, y argumentos
void runcmd(char *cmdline);

// crea los procesos hijos necesarios para ejecutar los comandos o pipes
void execline(char *cmdline);

#endif