#ifndef PARSER_H
#define PARSER_H

// Numero maximo de argumentos por comando, se puede modificar si se necedita
#define MAXARGS 32

// pasa la linea de texto a una linea de comandos e identifia las redirecciones <>
int parseline(char *buf, char **argv, char **infile, char **outfile);

// Busca el pipe con el caracter | para separar la linea en izqwuiera y derecha
char *findpipe(char *cmdline);

#endif