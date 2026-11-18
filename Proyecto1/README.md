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

Este proyecto implementa un shell (`sh.c`) para el sistema operativo educativo xv6. El programa lee comandos desde la entrada estándar, los interpreta y ejecuta los programas existentes en xv6 mediante la creación de nuevos procesos (`fork` + `exec`).

La implementación soporta:

- Ejecución de comandos simples.
- Ejecución de comandos con argumentos.
- Redirección de entrada (`<`).
- Redirección de salida (`>`).
- Tuberías simples y múltiples encadenadas (`|`).
- Comando interno `exit` para finalizar el shell.

**Nota:** estos archivos fueron posteriormente adaptados (firmas de `exit()`, `wait()`, `fprintf()`, rutas de `#include`) para poder compilar también sobre xv6-riscv, como parte del Proyecto 2. La versión usada aquí refleja esa adaptación.

---

# Estructura de archivos

```text
user/
├── sh.c
├── parser.c
├── parser.h
├── commands.c
└── commands.h
```

## Descripción de los archivos

### sh.c
Archivo principal del shell: lee comandos y coordina la ejecución.

### parser.c / parser.h
Separa la línea de comandos en argumentos y detecta redirección (`<`, `>`) y tuberías (`|`).

### commands.c / commands.h
Ejecuta comandos simples con redirección, y resuelve tuberías encadenadas mediante recursión.

---

# Decisiones de diseño

- Separación entre análisis sintáctico (`parser.c`) y ejecución (`commands.c`).
- Redirección implementada cerrando el descriptor estándar correspondiente y abriendo el archivo justo después.
- Tuberías múltiples resueltas de forma recursiva: cada llamada resuelve un solo pipe y delega el resto a una nueva llamada.
- El comando `exit` se evalúa antes de crear cualquier proceso hijo.

---

# Declaración de uso de IA

Durante el desarrollo se utilizaron herramientas de inteligencia artificial generativa como apoyo para comprensión de conceptos, revisión de código y resolución de errores de compilación y configuración del entorno.

Los integrantes asumen plena responsabilidad académica sobre el contenido entregado.
