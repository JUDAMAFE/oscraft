# Autoevaluación — Proyecto 2: System Calls en xv6

**Nombre:** Juan Daniel Martínez Fernández

---

## 1. Contribución al proyecto

Contribui a la implementacion completa de sysinfo, modificando el kernel y creando la logica de la syscall como tal en sysinfo.c y sysinfo.h, implementandola dentro del kernel y user de xv6

---

## 2. Comprensión de la solución




### ¿Cómo funciona `trace`?

`trace`: Esta syscall como tal es depuración y monitoreo, recibe una llamada que se debe revisar (en este caso usamos sys_kill, que hace que un proceso pare o cambie de estado)

Como tal lo que hace es vigilar esta función en tiempo real, mostrando su identificador de proceso (PID), un return que nos dice si se completó de manera exitosa y sus registros del hardware (siendo esta la parte de más bajo nivel)

### ¿Cómo funciona `sysinfo`?

`sysinfo`: En pocas palabras investiga el estado el sistema, que el user le diga a el kernel que mire cuántos procesos y recursos está consumiendo, lo cual kernel generalmente tiene guardado, pero la syscall recopila, empaqueta en C y lo pasa a user

---

## 3. Dificultades encontradas

Mas que todo las dificultades fueron en los kernel, en una parte cuando cambiaba para definir lo de sysinfo el proyecto no ejecutaba y tuve que buscar la manera de modificar la menor cantidad de archivos del kernel posible para que el proyecto no tuviera que tener tantos archivos kernel que tendria que modificar la persona que quiera correr el proyecto 

---

## 4. Aprendizajes

Aprendi como el usuario puede hacer llamadas al sistema y como se pueden crear nuevas que cumplen diferentes funciones, y como en modo usuario podemos llamar a kernel para que nos brinde esta informacion.

---

## 5. Autocalificación

**Nota que me asigno (sobre 5.0): 4.3** 

**Justificación:**

no he participado mucho en las clases pero siento que estoy presente y he asistido a todas las clases
