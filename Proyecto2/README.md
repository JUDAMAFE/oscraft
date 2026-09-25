# System Calls en xv6

## Información General

**Nombre del proyecto:** System Calls en xv6 — Implementación de `trace` y `sysinfo`

**Curso:** Sistemas Operativos — Universidad EAFIT — 2026-2

**Integrantes:**
- Juan Diego Martínez Jaramillo
- Juan Daniel Martínez Fernández

---

## Descripción de la Solución

Este proyecto extiende el kernel de **xv6-riscv** con dos nuevas llamadas al sistema orientadas al monitoreo e introspección:

### `trace`

Permite monitorear la ejecución de una syscall específica por nombre (por ejemplo `trace kill`). Una vez activado el monitoreo para el proceso actual, cada vez que ese proceso ejecute la syscall indicada, el kernel imprime en consola:

- PID del proceso
- Nombre de la syscall interceptada
- Valor de retorno de la syscall
- Contenido de los registros `s0`, `s1`, `a0` y `a1` del `trapframe` en el momento de la ejecución

### `sysinfo`

Recopila información del estado actual del sistema y la transfiere desde el kernel hacia el espacio de usuario mediante una estructura `struct sysinfo` definida por el equipo. La información reportada incluye:

- Memoria libre disponible (en bytes)
- Número de páginas físicas utilizadas
- Número de páginas físicas disponibles
- Número de procesos en estado `RUNNABLE`

Ambas syscalls se probaron directamente sobre el shell del equipo (desarrollado en el Proyecto 1), extendido para funcionar sobre xv6-riscv.

---

## Archivos Modificados

### Kernel

| Archivo | Descripción del cambio |
|---|---|
| `kernel/proc.h` | Se agregó el campo `traced_syscall` a `struct proc`, para registrar qué syscall está monitoreando cada proceso (0 = ninguna). |
| `kernel/proc.c` | Se inicializa `traced_syscall` en `freeproc()`. Se agregó la función `get_runnable_count()`, que recorre la tabla de procesos y cuenta cuántos están en estado `RUNNABLE`. |
| `kernel/kalloc.c` | Se agregó la función `get_free_memory()`, que recorre la lista de páginas libres del asignador de memoria física y calcula el total de memoria disponible en bytes. |
| `kernel/syscall.h` | Se agregaron los números de syscall `SYS_sysinfo` y `SYS_trace`. |
| `kernel/syscall.c` | Se agregó la tabla `syscallnames[]` (mapea número de syscall a su nombre en texto) y la función `syscallid_by_name()`, que busca el número de syscall correspondiente a un nombre dado. Se modificó la función `syscall()` para que, cuando la syscall ejecutada coincida con la que el proceso está monitoreando, imprima el PID, el nombre, el valor de retorno y los registros relevantes. |
| `kernel/sysproc.c` | Se implementaron `sys_sysinfo()` (llena la estructura `sysinfo` y la copia al espacio de usuario con `copyout`) y `sys_trace()` (recibe el nombre de la syscall como argumento, lo resuelve a un número con `syscallid_by_name()`, y lo guarda en `traced_syscall` del proceso actual). |
| `kernel/defs.h` | Se agregaron los prototipos de `get_free_memory()`, `get_runnable_count()` y `syscallid_by_name()` para que estén disponibles en los demás archivos del kernel. |

### Usuario

| Archivo | Descripción del cambio |
|---|---|
| `user/sysinfo.h` | Define la estructura `struct sysinfo`, compartida entre kernel y espacio de usuario, con los campos `freemem`, `n_upages`, `n_apages` y `n_runnable`. |
| `user/sysinfo.c` | Programa de usuario que invoca la syscall `sysinfo()` y muestra el resultado en pantalla (RF-04). |
| `user/trace.c` | Programa de usuario que invoca la syscall `trace()` con el nombre de una syscall como argumento, y luego ejecuta algunas llamadas al sistema (`kill`, `uptime`) para que el monitoreo tenga algo que reportar (RF-03). |
| `user/user.h` | Se agregaron los prototipos `int sysinfo(struct sysinfo*)` y `int trace(const char*)`. |
| `user/usys.pl` | Se agregaron las entradas `entry("sysinfo")` y `entry("trace")`, necesarias para que se generen automáticamente los stubs en ensamblador que realizan la llamada al sistema (`ecall`). |
| `user/sh.c`, `user/parser.c`, `user/commands.c` | Shell propio del equipo (desarrollado en el Proyecto 1), adaptado para compilar sobre xv6-riscv y usado para probar ambas syscalls de forma interactiva. |

### Build

| Archivo | Descripción del cambio |
|---|---|
| `Makefile` | Se agregaron `$U/_sysinfo` y `$U/_trace` a la lista `UPROGS`, y las reglas de compilación necesarias para el shell propio (`sh.c` + `parser.c` + `commands.c`). |

---

## Diseño Realizado

- **`sysinfo`** transfiere información del kernel al usuario mediante `copyout()`, copiando la estructura completa de una sola vez en lugar de transferir cada campo por separado, siguiendo el mismo patrón que usan otras syscalls existentes en xv6 (como `sys_fstat`).

- **`get_free_memory()`** recorre la lista enlazada de páginas libres (`kmem.freelist`) que ya mantiene el asignador de memoria física de xv6, sin necesidad de estructuras adicionales — cada nodo de la lista representa una página física libre de 4096 bytes.

- **`get_runnable_count()`** recorre la tabla global de procesos (`proc[]`) adquiriendo el lock de cada proceso antes de leer su estado, para evitar condiciones de carrera con el planificador.

- **`trace`** se implementó con un enfoque de "marca y verifica": en lugar de interceptar la syscall antes de ejecutarla, se deja que la syscall se ejecute normalmente y, justo después, se compara su número contra `traced_syscall` del proceso. Esto permite capturar también el valor de retorno real de la syscall, que la rúbrica pide mostrar.

- **`syscallid_by_name()`** resuelve el nombre de texto que el usuario escribe (por ejemplo `"kill"`) al número interno de la syscall, recorriendo la tabla `syscallnames[]`. Esto evita que el usuario tenga que conocer los números internos de las syscalls.

- El campo `traced_syscall` se agregó a `struct proc` en lugar de usar una variable global, para que el monitoreo sea **por proceso**: cada proceso puede monitorear una syscall distinta (o ninguna) de forma independiente.

---

## Compilación

Requiere el toolchain cruzado de RISC-V (`riscv64-unknown-elf-gcc` o equivalente) y QEMU (`qemu-system-riscv64`) instalados.

```bash
git clone https://github.com/mit-pdos/xv6-riscv.git
cd xv6-riscv
```

Copiar los archivos de este repositorio dentro de la carpeta clonada, respetando la estructura (`kernel/` y `user/`).

```bash
make clean
make qemu
```

---

## Ejecución

Una vez xv6 arranca, se abre automáticamente el shell del equipo. Desde ahí:

**Probar `sysinfo`:**
```
$ sysinfo
```

Salida esperada (los valores varían según el estado del sistema):
```
--- SYSINFO REPORT ---
Free memory (bytes): 133267456
Used pages: 232
Available pages: 32536
Runnable processes: 0
```

**Probar `trace`:**
```
$ trace kill
```

Salida esperada:
```
Monitoreo activado para: kill
PID actual: 5
PID: 5
SYSCALL: kill
RETURN: 0
s0: 0x...
s1: 0x...
a0: 0x0
a1: 0x...
```

Para salir de QEMU: `Ctrl+A` seguido de `X`.

---

## Uso de IA Generativa

Durante el desarrollo del proyecto se utilizaron herramientas de inteligencia artificial generativa como apoyo para:

- Comprensión de conceptos de sistemas operativos (llamadas al sistema, transferencia de datos entre espacio de kernel y usuario, estructura del `trapframe` en RISC-V).
- Resolución de errores de compilación y enlazado surgidos al adaptar código entre distintas versiones de xv6 (xv6-public y xv6-riscv), incluyendo diferencias en las firmas de `exit()`, `wait()`, `printf()` y `kill()`.
- Configuración del entorno de desarrollo (WSL, toolchain cruzado de RISC-V, QEMU).
- Revisión de código y generación de ejemplos para la implementación de `sys_trace()` y `sys_sysinfo()`.

Los integrantes son responsables del código entregado, comprenden completamente su implementación y están en capacidad de explicar y justificar cualquier fragmento de código durante la sustentación.
