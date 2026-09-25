# Autoevaluación — Proyecto 2: System Calls en xv6

Nombre: Juan Diego Martínez Jaramillo

---



## 1. Contribución al proyecto

Trabajé principalmente en la implementación de la syscall `trace`: agregar el campo `traced_syscall` a `struct proc`, registrar el número de syscall en `kernel/syscall.h`, construir la tabla de nombres y la función `syscallid_by_name()` en `kernel/syscall.c`, modificar la función `syscall()` para que imprima la información de monitoreo, implementar `sys_trace()` en `kernel/sysproc.c`, y crear el programa de usuario `user/trace.c` para probarla.

También me encargué de redactar el `README.md` del proyecto, documentando la descripción de la solución, los archivos modificados, las decisiones de diseño y los pasos de compilación y ejecución.


---

## 2. Comprensión de la solución

## ¿Cómo funciona `trace`?

`trace` es una herramienta de depuración y monitoreo: se le indica el nombre de una llamada al sistema (en nuestras pruebas usamos `kill`, que detiene o cambia el estado de un proceso), y a partir de ese momento el kernel queda "atento" a esa syscall específica para ese proceso.

Cuando el proceso vuelve a invocar esa llamada, `trace` reporta en tiempo real qué pasó: el identificador del proceso (PID), el valor de retorno (que indica si la operación se completó correctamente), y el contenido de algunos registros del procesador en ese instante — esta última parte es la más cercana al hardware, ya que expone el estado interno del CPU justo durante la ejecución de la syscall.

### ¿Cómo funciona `sysinfo`?

`sysinfo` consulta el estado interno del sistema operativo. El usuario le pide al kernel esta información, y el kernel —que ya lleva internamente el control de cuántos procesos y recursos hay en uso— la recopila, la organiza en una estructura de C, y la entrega de vuelta al espacio de usuario.
---

## 3. Dificultades encontradas

Lo más difícil fue pasar el código del Proyecto 1 (hecho para xv6-public) a xv6-riscv, porque varias funciones cambian: `exit()`, `wait()` y `kill()` ahora piden argumentos que antes no llevaban, y hay que escribir las rutas de los `#include` de otra forma.

También nos topamos varias veces con el mismo error al compilar: "undefined reference". Aprendimos que eso pasaba porque nos faltaba agregar la syscall nueva en el archivo `usys.pl`, que es el que genera el código que realmente hace la llamada al kernel.

Otro problema fue que definimos la misma estructura (`struct sysinfo`) dos veces sin darnos cuenta, porque se incluía desde dos archivos distintos.

Por fuera del código, también nos tomó tiempo dejar bien instalado el entorno en WSL
---

## 4. Aprendizajes

Aprendí cómo el kernel y los programas de usuario se comunican mediante llamadas al sistema, y qué pasa realmente detrás de una syscall

También entendí mejor cómo se organiza un proceso por dentro (`struct proc`), y cómo se puede usar un campo simple, como `traced_syscall`, para que cada proceso "recuerde" qué está monitoreando sin afectar a los demás.



---

## 5. Autocalificación

**Nota que me asigno (sobre 5.0):* 4.3*

**Justificación:**
He faltado a algunas clases y mayormente estudio por fuera de la clase en vez de con las explicaciones del profesor, a demas siento que nos demoramucho en avanzar con el proyecto
