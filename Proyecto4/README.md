# Proyecto de Sistemas Operativos
## Proyecto 4: Copy-on-Write y MiniDB (xv6)

### Integrantes

- Juan Diego Martínez Jaramillo
- Juan Daniel Martínez Fernández

### Curso

Sistemas Operativos

### Semestre

2026-2

---

# Descripción

Partimos de xv6-riscv (commit `06aad25`) con la solución de referencia del Proyecto 3 (`base_proyecto3.patch`).

- **Parte A (Copy-on-Write).** `fork()` ya no copia la memoria: el hijo apunta a las mismas páginas físicas que el padre. Esas páginas se marcan sin permiso de escritura y con un bit propio (`PTE_COW`, el bit 8 de la PTE). Cuando alguno de los dos escribe, el procesador provoca un page fault; el kernel entonces copia la página (solo si todavía la usa más de un proceso) y le devuelve el permiso de escritura. Cada página física tiene un contador de referencias, protegido con un spinlock, que decide cuándo se puede liberar.
- **Parte B (`cowstat()`).** Una llamada al sistema nueva que informa las páginas libres, las páginas compartidas y, para el proceso que llama, cuántos fallos CoW atendió y cuántos terminaron en una copia.
- **Parte C (MiniDB).** Completamos `minidb snapshot M`: el padre hace `fork()`; el hijo escribe la tabla en `snap.db` mientras el padre sigue aplicando transferencias. Gracias a CoW el hijo ve la tabla "congelada" en el instante del `fork()`, y solo se copian las páginas que el padre modifica.

---

# Archivos modificados

## kernel/

- **riscv.h**: define `PTE_COW` como `1L << 8` (bit RSW, reservado para el software).
- **kalloc.c**: arreglo `refs.cuenta[]` con un contador por página física entre `KERNBASE` y `PHYSTOP`, protegido por `refs.lock`. `kalloc()` deja la cuenta en 1; `krefinc()` suma una referencia; `kfree()` resta una y solo devuelve la página a la lista libre cuando llega a 0. `freerange()` pone la cuenta en 1 antes de llamar a `kfree()`, porque esas páginas nunca pasaron por `kalloc()`. También se agregaron `krefcount()`, `kfreepages()` y `ksharedpages()` (usadas por `cowstat()`).
- **vm.c**:
  - `uvmcopy()` ya no copia: mapea la misma página en el hijo y sube su contador. Si la página era escribible, le quita `PTE_W` y le pone `PTE_COW` en el padre y en el hijo; las de solo lectura (código) se comparten tal cual.
  - `cowfault(pagetable, va)` (nueva): atiende el fallo de escritura. Si la página tiene más de una referencia reserva otra, copia, mapea con `PTE_W` y sin `PTE_COW`, y baja la referencia de la vieja. Si tiene una sola, solo devuelve `PTE_W`. Si no hay memoria, devuelve -1.
  - `copyout()` llama a `cowfault()` cuando la página destino tiene `PTE_COW`; si no es CoW y no tiene `PTE_W`, sigue devolviendo -1 como antes.
- **trap.c**: en `usertrap()`, un fallo de escritura (`scause` 15) se intenta primero con `cowfault()`. Si devuelve -1 (no es CoW o no hay memoria) el flujo sigue como antes: `vmfault()` para páginas perezosas y, si tampoco aplica, el proceso se mata con `setkilled()` (sin pánico).
- **proc.h / proc.c**: campos `cowfaults` y `cowcopies` en `struct proc`, puestos en 0 en `allocproc()`.
- **cowstat.h** (nuevo): la estructura `struct cowstat`.
- **sysproc.c**: `sys_cowstat()`, que llena la estructura y la entrega con `copyout()`.
- **syscall.h / syscall.c**: `SYS_cowstat` = 25 y su entrada en la tabla.
- **defs.h**: prototipos de las funciones nuevas.

## user/

- **usys.pl / user.h**: la llamada `cowstat()`.
- **minidb.c**: `guardar_snapshot()` y `snapshot()` (el resto del esqueleto no se tocó).

## Makefile

- Se agregaron `$U/_pgtbltest`, `$U/_cowtest` y `$U/_minidb` a `UPROGS`.

---

# Integración con xv6

1. Clonar xv6-riscv, hacer `git switch -c proyecto4 06aad25` y aplicar `git apply base_proyecto3.patch`.
2. Copiar los archivos entregados en sus rutas.
3. Copiar los archivos del docente: `user/cowtest.c`, `user/minidb.h`, `user/pgtbltest.c` y `user/usertests.c`.
4. Compilar con `make qemu CPUS=3`.
5. Ejecutar `cowtest`, `minidb consulta 3`, `minidb snapshot 2000`, `pgtbltest` y `usertests -q`.

---

# Respuestas a las preguntas

## 1. PTE antes y después de una escritura CoW

Con `minidb mapa`, la primera página de la tabla es la de la dirección `0x6000`.

| | PTE | Dirección física | Bits |
|---|---|---|---|
| Hijo, antes de escribir | `0x21fd11d3` | `0x87f44000` | V=1 R=1 W=0 X=0 U=1 A=1 D=1 **COW=1** |
| Hijo, después de escribir | `0x21fb28d7` | `0x87eca000` | V=1 R=1 **W=1** X=0 U=1 A=1 D=1 COW=0 |

Los bits bajos son `0x1d3` y `0xd7`. En `0x1d3` están prendidos V (0x01), R (0x02), U (0x10), A (0x40), D (0x80) y COW (0x100); falta W, así que la escritura provoca el page fault. En `0xd7` ya está W (0x04) y COW se apagó.

La dirección física cambió porque el kernel copió la página: antes el hijo compartía la página del padre (`0x87f44000`, con 2 referencias). En el fallo reservó una página nueva (`0x87eca000`), copió el contenido, la mapeó con permiso de escritura y le bajó una referencia a la vieja.

La PTE del padre **no cambia en ese momento**: sigue apuntando a `0x87f44000`, sin W y con COW. Pero ahora esa página tiene una sola referencia, así que cuando el padre escriba no se copiará nada: el kernel solo le devolverá `PTE_W` y le quitará `PTE_COW`.

## 2. Páginas sin PTE_W y USYSCALL en fork()

Las páginas que ya no tenían `PTE_W` (el código del programa) se comparten tal cual: `uvmcopy()` las mapea en el hijo, sube su contador y **no** les pone `PTE_COW`. La página de guarda de la pila (sin `PTE_U`) también se comparte sin `PTE_COW`, así que cualquier acceso del usuario sigue fallando. `USYSCALL` y el trapframe no se copian en `uvmcopy()` (que solo recorre hasta `p->sz`): cada proceso crea los suyos en `allocproc()`.

No se marcan como CoW porque `PTE_COW` significa "no escribible *por ahora*, pero lo era". Si se marcara el código como CoW, el primer intento de escribir en él se "arreglaría" copiando la página y dando permiso de escritura, y un proceso podría modificar su propio código. Con las páginas sin `PTE_COW`, `cowfault()` devuelve -1 y el proceso muere, que es lo correcto (lo comprueba la prueba `solo_lectura`).

Si `USYSCALL` se compartiera, el hijo vería la página del padre, que guarda el pid del padre. `ugetpid()` del hijo devolvería el pid del padre en vez del suyo.

## 3. Carrera en el conteo de referencias

Supongamos una página P con 2 referencias (padre A y su hijo B) y que el conteo `n` se maneja sin lock con `n = n - 1` (leer, restar, escribir).

1. A y B terminan casi al mismo tiempo, cada uno en su CPU, y los dos llaman a `kfree(P)`.
2. La CPU 0 lee `n = 2`. La CPU 1 también lee `n = 2`.
3. Cada una calcula 1 y escribe 1.
4. Resultado: el conteo quedó en 1 cuando debía ser 0. **Nadie libera P y la página se pierde para siempre** (fuga).

El caso contrario ocurre con el aumento: en `fork()` el padre sube el contador (`n = n + 1`) mientras otro proceso que comparte la página termina y lo baja. Si se pisan las escrituras, el conteo puede quedar en 1 aunque 2 procesos la usan; cuando uno termina, `kfree()` ve 0 y devuelve la página a la lista libre mientras el otro todavía la tiene mapeada. Luego `kalloc()` se la entrega a otro proceso y los dos comparten una página sin saberlo: se corrompen los datos.

Con `refs.lock`, cada lectura-modificación-escritura del contador es una sola operación indivisible entre CPUs, y estas secuencias no pueden ocurrir. Basta un solo lock global porque las secciones críticas son muy cortas (una suma o una resta) y no hay otro lock que se tome adentro, por lo que no hay deadlock.

## 4. Consistencia del snapshot

- **Por qué `snap.db` tiene el checksum de antes del fork.** Al hacer `fork()`, el hijo comparte las páginas de la tabla con el padre, todas marcadas CoW. Cuando el padre modifica una cuenta, el kernel le da al padre (o al hijo, según quién escriba primero) una copia propia; el hijo sigue viendo el contenido original. Por eso el hijo escribe la tabla exactamente como estaba en el instante del `fork()`, aunque el padre ya haya cambiado muchas cuentas. Lo comprueban `checksum=...  coincide=si` y que `checksum_actual` (con las transferencias) sea distinto.
- **Por qué `copias_cow` < 64.** La tabla ocupa 64 páginas, pero el padre solo copia las que escribe. Casi todas las transferencias (255 de cada 256) ocurren entre las 1024 cuentas más activas (8 páginas) y el resto cae en cuentas al azar; con 2000 transferencias el padre toca unas 30 páginas (`paginas_tocadas=30`), y cada una se copia una sola vez. Las otras 34 siguen compartidas con el hijo sin ninguna copia.
- **Si el padre esperara al hijo antes de transferir.** Con el hijo ya terminado, cada página tendría una sola referencia. Los fallos seguirían ocurriendo (`fallos_cow` ≈ 30, uno por página escrita, porque la PTE sigue siendo CoW), pero `copias_cow` sería 0: el kernel solo devolvería `PTE_W`. Además perderíamos la gracia del snapshot: las transferencias quedarían detenidas hasta que termine de escribirse el archivo.

## 5. Aceleración y planificador

Ticks medidos de `minidb consulta K` (ver el reporte para la tabla completa):

| K | 1 | 2 | 3 | 4 | 8 |
|---|---|---|---|---|---|
| CPUS=1 | 40 | 40 | 41 | 38 | 44 |
| CPUS=3 | 42 | 22 | 22 | 22 | 22 |

(Medidos en un computador con 2 núcleos físicos disponibles; en uno con 3 o más núcleos libres K=3 baja más.)

- **De 1 a 3 trabajadores con CPUS=3.** Cada trabajador es un proceso independiente que usa solo CPU (la firma). xv6 tiene un planificador Round Robin por CPU libre: cada CPU toma de la tabla de procesos el siguiente proceso listo (RUNNABLE). Con 3 CPUs, hasta 3 trabajadores corren al mismo tiempo y el trabajo se reparte entre ellas, así que el tiempo baja.
- **De 3 a 8.** Solo hay 3 CPUs. Los trabajadores extra no tienen CPU libre: quedan en RUNNABLE esperando su turno y el Round Robin los va intercalando cada vez que ocurre la interrupción de reloj. El trabajo total es el mismo y las CPUs ya estaban ocupadas, así que el tiempo no mejora; además hay un poco más de costo en cambios de contexto y en crear más procesos.
- **Con CPUS=1.** Hay un solo núcleo; aunque haya 8 procesos, solo uno corre a la vez y los demás esperan. Round Robin los alterna, pero la suma del trabajo es la misma, por eso los ticks no bajan con K (varían un poco por el costo de los cambios de contexto y de `fork()`).

---

# Resultados de las pruebas

Salida completa en `pruebas/`, generada con `ejecutar_pruebas.py` y 3 CPUs.

| Suite | Resultado |
|---|---|
| `cowtest` | 11 de 11 pruebas OK |
| `minidb` | `consulta` 1, 2, 3 y 8: OK; `snapshot 2000` y `snapshot 0`: OK; `mapa`: PTE con COW antes y W después |
| `pgtbltest` | PASÓ |
| `usertests -q` | ALL TESTS PASSED |

El kernel compila con `make qemu` sin advertencias (flags `-Wall -Werror`).

---

# Decisiones de diseño

- **Un solo lock para todos los contadores** (`refs.lock`): las secciones críticas son de una instrucción y nunca se toma otro lock adentro. No se mantiene `refs.lock` mientras se toma `kmem.lock`, así que no hay deadlock.
- **`cowfault()` está en `vm.c` y la usan `usertrap()` y `copyout()`**, para que la lógica de copiar o solo devolver `PTE_W` exista una vez.
- **El orden en `cowfault()`**: primero se mapea la página nueva y después se hace `kfree()` de la vieja, así el mapeo nunca apunta a una página liberada.
- **Los contadores de cowstat son por proceso**, en `struct proc`; `freepages` y `sharedpages` son globales y se calculan al momento de la llamada.
- **`guardar_snapshot()` escribe la tabla página por página** directamente desde memoria (sin copiarla), para no superar el tamaño máximo de una transacción del log del sistema de archivos.

---

# Limitaciones conocidas

- `kfreepages()` y `ksharedpages()` recorren la lista libre / el arreglo completo (unas 32 mil entradas) en cada llamada a `cowstat()`; es suficiente para el proyecto pero no es eficiente.
- No se hace CoW de las páginas de las tablas de páginas ni de las estructuras del kernel, solo de las páginas de datos del proceso (fuera del alcance).
- No se recupera la tabla desde `snap.db` al iniciar (fuera del alcance).
- Un solo lock global para todos los contadores podría ser un cuello de botella con muchas CPUs.

---

# Declaración de uso de IA

Se usó Claude (Anthropic) como apoyo para entender el enunciado, escribir y depurar la implementación, y redactar el README y el reporte. Los integrantes revisaron, probaron en QEMU y asumen plena responsabilidad académica sobre el contenido entregado y pueden explicarlo.
