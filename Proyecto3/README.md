# Proyecto de Sistemas Operativos
## Proyecto 3: Tablas de páginas en acción (xv6)

### Integrantes

- Juan Diego Martínez Jaramillo
- Juan Daniel Martínez Fernández

### Curso

Sistemas Operativos

### Semestre

2026-2

---

# Descripción

En este proyecto agregamos tres cosas a xv6-riscv (commit `06aad25`). Las tres usan la tabla de páginas de cada proceso.

- **Parte A: página compartida y `ugetpid()`.** El kernel le da a cada proceso una página de memoria que el proceso solo puede leer. En esa página el kernel guarda el pid. Así, `ugetpid()` lee el pid directamente de memoria y no necesita hacer una llamada al sistema.
- **Parte B: `vmprint()`.** Es una llamada al sistema que imprime la tabla de páginas del proceso que la llama. Muestra cada página válida con su dirección virtual, su PTE y su dirección física.
- **Parte C: `pgaccess()`.** Es una llamada al sistema que dice qué páginas de un proceso fueron leídas o escritas desde la última vez que se preguntó. Usa el bit de acceso (`PTE_A`) que el hardware enciende solo.

---

# Archivos modificados

## kernel/

| Archivo | Qué se cambió y por qué |
|---|---|
| `memlayout.h` | Se definió `USYSCALL`, la dirección de la página compartida (justo debajo del trapframe), y la estructura `struct usyscall` con el campo `pid`. Va dentro de `#ifndef __ASSEMBLER__` porque este archivo también lo leen archivos en ensamblador. |
| `riscv.h` | Se definió `PTE_A`, el bit 6 de la PTE, que indica que la página fue usada. |
| `proc.h` | Se agregó a `struct proc` el campo `usyscall`, que apunta a la página compartida de ese proceso. |
| `proc.c` | `allocproc()` reserva la página con `kalloc()`, la llena de ceros y guarda el pid. `proc_pagetable()` la mapea en `USYSCALL` con permisos de lectura y usuario. `freeproc()` y `proc_freepagetable()` la liberan al terminar el proceso. `growproc()` ahora compara contra `USYSCALL` para que el heap no la invada. |
| `vm.c` | Se agregó `vmprint()` y la función recursiva `vmprint_nivel()`, que recorre los tres niveles de la tabla como lo hace `freewalk()`. |
| `sysproc.c` | `sys_sbrk()` compara contra `USYSCALL`. Se agregaron `sys_vmprint()` y `sys_pgaccess()`. |
| `syscall.h` | Números de las llamadas nuevas: `SYS_vmprint` (23) y `SYS_pgaccess` (24). |
| `syscall.c` | Se registraron `sys_vmprint` y `sys_pgaccess` en la tabla de llamadas al sistema. |
| `defs.h` | Prototipo de `vmprint()`. |

## user/

| Archivo | Qué se cambió y por qué |
|---|---|
| `ulib.c` | Se agregó `ugetpid()`, que lee el pid de `USYSCALL` sin llamar al kernel. |
| `user.h` | Prototipos de `ugetpid()`, `vmprint()` y `pgaccess()`. |
| `usys.pl` | Entradas `vmprint` y `pgaccess`, para que se generen las funciones de usuario de las dos llamadas nuevas. |

---

# Integración con xv6

1. Clonar xv6-riscv y hacer `git switch -c proyecto3 06aad25`.
2. Copiar los archivos entregados en sus rutas.
3. Agregar `$U/_pgtbltest` a UPROGS en el Makefile.
4. Compilar con `make qemu`.
5. Ejecutar `pgtbltest` y `usertests -q`.

---

# Respuestas a las preguntas

## 1. Interpretación de vmprint()

Esta es la salida de `vmprint()` de un proceso de prueba, solo las líneas de las páginas reales (las de tres niveles):

```text
 .. .. ..0x0000000000000000: pte 0x0000000021fc9c5b pa 0x0000000087f27000
 .. .. ..0x0000000000001000: pte 0x0000000021fc985b pa 0x0000000087f26000
 .. .. ..0x0000000000002000: pte 0x0000000021fc94d7 pa 0x0000000087f25000
 .. .. ..0x0000000000003000: pte 0x0000000021fd1407 pa 0x0000000087f45000
 .. .. ..0x0000000000004000: pte 0x0000000021fd08d7 pa 0x0000000087f42000
 .. .. ..0x0000003fffffd000: pte 0x0000000021fc9013 pa 0x0000000087f24000
 .. .. ..0x0000003fffffe000: pte 0x0000000021fca4c7 pa 0x0000000087f29000
 .. .. ..0x0000003ffffff000: pte 0x000000002000184b pa 0x0000000080006000
```

Los dos últimos dígitos de la PTE son los permisos (flags): `V`=válida, `R`=leer, `W`=escribir, `X`=ejecutar, `U`=accesible desde el modo usuario, `A`=ya fue usada, `D`=ya fue modificada.

| Dirección virtual | Flags | Qué contiene |
|---|---|---|
| `0x0000` y `0x1000` | `5b` = V R X U A | **Texto** (el código). Se lee y se ejecuta, pero no se escribe, para que el programa no cambie su propio código. |
| `0x2000` | `d7` = V R W U A D | **Datos**. Se lee y se escribe. |
| `0x3000` | `07` = V R W, sin U | **Página de guarda**. El usuario no puede usarla. |
| `0x4000` | `d7` | **Pila**. Se lee y se escribe. |
| `0x3fffffd000` | `13` = V R U | **USYSCALL**. El usuario solo puede leerla. |
| `0x3fffffe000` | `c7` = V R W A D, sin U | **Trapframe**. Solo lo usa el kernel. |
| `0x3ffffff000` | `4b` = V R X A, sin U | **Trampolín**. Es el código que pasa de modo usuario a modo kernel y al revés. Solo lo usa el kernel. |

Las líneas con uno y dos `..` (por ejemplo `..0x0000000000000000: pte ...2001`) solo tienen el bit `V`: no son páginas, apuntan a la tabla del nivel siguiente.

Si el proceso reserva memoria con `sbrklazy()`, esas páginas no aparecen hasta que el proceso las usa. En la salida de la prueba, de 8 páginas reservadas solo apareció la de `0x8000`, que fue la que el programa tocó.

## 2. Página de guarda

La página de guarda no tiene `PTE_U` para que un programa no pueda usarla. Está justo debajo de la pila. Si un programa usa demasiada pila (por ejemplo, con una recursión que no termina), llega a esa página. Como el usuario no puede tocarla, el hardware avisa al kernel con un fallo de página y el kernel termina al proceso. Sin la página de guarda, la pila seguiría creciendo sobre los datos del programa y los dañaría sin que nadie se diera cuenta.

## 3. Otras llamadas que se pueden acelerar

Se pueden acelerar las llamadas que **solo devuelven un dato que el kernel ya tiene y que no cambia nada en el sistema**. El kernel deja el dato en la página compartida y el usuario lo lee:

- `getpid()`, que ya está hecha.
- `uptime()`, si el kernel actualizara el contador de ticks en una página compartida. Esa página tendría que ser una sola para todos los procesos, porque el tiempo es el mismo para todos.

No se pueden acelerar las que **cambian el estado del sistema o necesitan que el kernel haga algo**: `fork`, `exec`, `exit`, `wait`, `kill`, `sbrk`, `open`, `close`, `read`, `write`, `pipe`, `dup`, `chdir`, `mkdir`, `unlink`, `link`, `mknod`, `fstat`, `sync` y `pause`. Para todas ellas el kernel tiene que ejecutar código, y leer una página no lo hace ejecutar nada.

## 4. Riesgo de USYSCALL con PTE_W

Esa página es memoria del kernel. Si se mapeara con `PTE_W`, el proceso podría escribir en ella. El proceso podría cambiar el pid y `ugetpid()` daría un pid falso. Si algún día el kernel o un programa confiara en ese dato para decidir permisos, un proceso podría hacerse pasar por otro. Además, cualquier dato que se agregue después a la página quedaría bajo control del usuario. Por eso se mapea solo con `PTE_R | PTE_U`: si el proceso intenta escribir, hay un fallo de página y el kernel lo termina.

## 5. pgaccess() y páginas perezosas

Una página de `sbrklazy()` que no se ha tocado todavía **no tiene memoria física**: el kernel solo aumentó el tamaño del proceso. Como no tiene PTE válida, el hardware nunca pudo encender el bit `PTE_A`, y nadie ha leído ni escrito esa página. Por eso `pgaccess()` la reporta como 0.

`pgaccess()` no debe asignarle memoria por dos razones:

- Preguntar no debe cambiar lo que se pregunta. Si la consulta le diera memoria a la página, la siguiente consulta podría verla como usada aunque el proceso nunca la usó.
- Se perdería el sentido de la asignación perezosa. Un proceso podría gastar toda la memoria solo llamando a `pgaccess()` sobre un rango enorme.

Por eso `pgaccess()` usa `walk()` con `alloc = 0`, que busca la PTE pero no crea nada.

---

# Resultados de las pruebas

La salida completa está en `pruebas/pgtbltest.txt` y `pruebas/usertests.txt`, generada con el script `ejecutar_pruebas.py` sobre el kernel entregado.

- **`pgtbltest`:** pasaron las 11 pruebas (`TODAS LAS PRUEBAS PASARON (11 de 11)`) y la revisión del formato de `vmprint()` dio OK.
- **`usertests -q`:** terminó con `ALL TESTS PASSED`, sin `panic`. Los mensajes `usertrap(): unexpected scause ...` que se ven durante la prueba son normales: varias pruebas hacen accesos inválidos a propósito y el kernel termina esos procesos.

---

# Decisiones de diseño

- **La página compartida se llena de ceros** con `memset()` antes de guardar el pid. `kalloc()` entrega páginas con datos viejos, y sin limpiarla el proceso podría leer información del kernel desde `USYSCALL`.
- **El pid se guarda en `allocproc()`**, antes de crear la tabla de páginas, para que la página ya tenga el dato cuando se mapea. Así funciona igual en procesos nuevos, en hijos de `fork()` y después de `exec()`.
- **La página se libera una sola vez.** `proc_freepagetable()` solo la desmapea (`uvmunmap` sin liberar) y `freeproc()` la libera con `kfree()`.
- **`vmprint()` sigue el modelo de `freewalk()`:** una función recursiva que baja un nivel cuando la PTE no tiene permisos de leer, escribir ni ejecutar. La dirección virtual se calcula con el número de entrada y el nivel.
- **`pgaccess()` hace dos recorridos.** Primero lee los bits `PTE_A` y arma la máscara. Luego copia la máscara al usuario con `copyout()`. Solo si la copia funcionó, el segundo recorrido limpia los bits. Así, si el puntero que mandó el usuario es inválido, no se pierde la información de accesos.
- **`pgaccess()` usa `walk()` con `alloc = 0`** para no asignar memoria a las páginas perezosas.
- **Al limpiar `PTE_A` se llama a `sfence_vma()`.** Esta instrucción obliga al hardware a olvidar las traducciones que tenía guardadas. Sin ella, el hardware seguiría usando la traducción vieja, que tiene el bit encendido, y no lo volvería a encender en el siguiente acceso.
- **`pgaccess()` valida los argumentos:** `base` alineada a página, `npages` entre 1 y 64, y que el rango esté dentro del tamaño del proceso (también se revisa que la suma no se desborde).

---

# Limitaciones conocidas

- `pgaccess()` acepta como máximo 64 páginas por llamada, porque el resultado cabe en un solo número de 64 bits.
- La página compartida solo guarda el pid. No se aceleraron otras llamadas al sistema.
- `sfence_vma()` descarta todas las traducciones guardadas, no solo las de las páginas consultadas. Es correcto, pero menos eficiente.
- `pgaccess()` depende de que el hardware (aquí, QEMU) encienda el bit `PTE_A` cuando se usa una página.
- Si dos procesos llaman a `vmprint()` al mismo tiempo en distintos núcleos, sus líneas pueden mezclarse en la pantalla.

---

# Declaración de uso de IA

Se usó Claude (Anthropic) como apoyo para entender los conceptos del proyecto (tablas de páginas Sv39, bits de las PTEs, página compartida), para revisar el código del kernel, para preparar una primera versión de la implementación de las Partes A, B y C, y para resolver errores de compilación y de configuración del entorno (WSL, Git, Makefile).

Los integrantes asumen plena responsabilidad académica sobre el contenido entregado y están en capacidad de explicar y justificar cada fragmento de código incluido en la entrega.
