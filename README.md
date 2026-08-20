# Proyecto de Sistemas Operativos
## Implementación de un Shell para xv6

### Integrantes

- Juan Diego Martínez Jaramillo
- Juan Daniel Martínez Fernández

### Curso

Sistemas Operativos

### Semestre

2026-2

---

# Descripción

Este proyecto implementa un shell (`sh.c`) para el sistema operativo educativo **xv6**. El programa lee comandos desde la entrada estándar, los interpreta y ejecuta los programas existentes en xv6 mediante la creación de nuevos procesos (`fork` + `exec`).

La implementación soporta:

- Ejecución de comandos simples.
- Ejecución de comandos con argumentos.
- Redirección de entrada (`<`).
- Redirección de salida (`>`).
- Tuberías simples y múltiples encadenadas (`|`).
- Comando interno `exit` para finalizar el shell.

La solución fue desarrollada en lenguaje C y se integra al proceso de compilación estándar de xv6 (versión xv6-public), ejecutado sobre QEMU.

---

# Estructura de archivos

```text
sh.c
parser.c
parser.h
commands.c
commands.h
```

## Descripción de los archivos

### sh.c

Archivo principal del shell. Contiene `getcmd()` (lee la línea escrita por el usuario y muestra el prompt `$`) y `main()` (el ciclo principal: lee un comando, revisa si es `exit`, y si no, crea un proceso hijo que delega la ejecución a `execline()`).

### parser.c / parser.h

Contiene `parseline()`, que separa la línea de comandos en argumentos (`argv`) y detecta los operadores de redirección `<` y `>`, guardando el nombre del archivo correspondiente sin incluirlo en los argumentos. También contiene `findpipe()`, que busca el primer `|` en la línea y la corta en dos partes.

### commands.c / commands.h

Contiene `runcmd()`, que ejecuta un comando simple aplicando redirección de archivos si corresponde, y `execline()`, que resuelve una línea con cero o más tuberías encadenadas mediante `fork()`, `pipe()` y recursión (cada llamada resuelve un pipe, y el lado derecho se vuelve a analizar llamando a `execline()` de nuevo).

---

# Integración con xv6

## Paso 1. Obtener xv6

```bash
git clone <repositorio de xv6-public>
```

## Paso 2. Copiar archivos

Copiar `sh.c`, `parser.c`, `parser.h`, `commands.c` y `commands.h` a la raíz del repositorio de xv6 (reemplazando el `sh.c` original).

## Paso 3. Modificar el Makefile

Como el shell ahora se compila a partir de tres archivos `.c` en vez de uno solo, se agregó una regla específica para `_sh` (en vez de usar la regla genérica `_%: %.o $(ULIB)`):

```makefile
_sh: sh.o parser.o commands.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o _sh sh.o parser.o commands.o $(ULIB)
	$(OBJDUMP) -S _sh > sh.asm
	$(OBJDUMP) -t _sh | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > sh.sym
```

## Paso 4. Compilar xv6

```bash
make clean
make qemu
```

## Paso 5. Ejecutar el shell

El shell se ejecuta automáticamente al arrancar xv6 (es lanzado por `init`).

---

# Casos de prueba

- Ejecución simple: `ls`
- Argumentos: `echo hola mundo`
- Redirección de salida: `echo hola > salida.txt`
- Redirección de entrada: `cat < salida.txt`
- Tubería simple: `echo hola | wc`
- Tuberías múltiples: `cat README | grep the | wc`
- Comando `exit`.
- Manejo de error: comando inexistente (ej. `x`) no rompe el shell, imprime `exec x failed` y continúa.

---

# Decisiones de diseño

- Separación entre análisis sintáctico (`parser.c`) y ejecución (`commands.c`), manteniendo `sh.c` únicamente con el ciclo principal de lectura de comandos.
- `parseline()` detecta `<` y `>` en la misma pasada en que separa los argumentos, evitando que el nombre del archivo o el símbolo de redirección terminen dentro de `argv`.
- La redirección de archivos se implementa cerrando el descriptor estándar correspondiente (0 o 1) y abriendo el archivo justo después, aprovechando que el sistema operativo asigna al nuevo archivo el descriptor libre más bajo.
- Las tuberías múltiples se resuelven de forma recursiva: `execline()` solo resuelve el primer `|` de la línea; todo lo que queda a la derecha se vuelve a pasar a la misma función, permitiendo encadenar cualquier cantidad de comandos.
- En cada pipe, el proceso padre cierra ambos extremos del pipe después de crear los hijos, para evitar que el proceso lector se quede esperando datos indefinidamente.
- El comando `exit` se evalúa antes de crear cualquier proceso hijo, ya que debe terminar el shell mismo y no un proceso hijo.

---

# Limitaciones conocidas

- No soporta comillas simples o dobles.
- No soporta variables de entorno ni sustitución de variables.
- No soporta expansión de comodines.
- No soporta ejecución en segundo plano ni control de trabajos.
- No implementa `cd`, `history`, `jobs`, `fg`, `bg` ni `kill` (fuera del alcance del proyecto).

---

# Declaración de uso de IA

Durante el desarrollo del proyecto se utilizaron herramientas de inteligencia artificial generativa como apoyo para comprensión de conceptos (fork, exec, pipe, descriptores de archivo), revisión de código, generación de ejemplos y resolución de errores de configuración del entorno de desarrollo (WSL, Git, Makefile).

Los integrantes asumen plena responsabilidad académica sobre el contenido entregado y están en capacidad de explicar y justificar cada fragmento de código incluido en la entrega.
