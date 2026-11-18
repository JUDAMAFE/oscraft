[README.md](https://github.com/user-attachments/files/34284657/README.md)
# oscraft

Proyectos del curso **Sistemas Operativos** (2026-2), Ingeniería de Sistemas, Universidad EAFIT.

### Integrantes

- Juan Diego Martínez Jaramillo
- Juan Daniel Martínez Fernández

---

# Proyectos

| Carpeta | Proyecto | Resumen |
|---|---|---|
| [`Proyecto1/`](Proyecto1/) | Shell para xv6 | Un shell en C para xv6 que ejecuta comandos con argumentos, redirección de entrada y salida (`<`, `>`), tuberías (`\|`) y el comando `exit`. |
| [`Proyecto2/`](Proyecto2/) | Llamadas al sistema en xv6-riscv | Dos llamadas nuevas: `trace`, que vigila una llamada al sistema, y `sysinfo`, que informa memoria libre, páginas y procesos listos. |
| [`Proyecto3/`](Proyecto3/) | Tablas de páginas en acción | Una página compartida con `ugetpid()`, la llamada `vmprint()` que imprime la tabla de páginas y la llamada `pgaccess()` que detecta qué páginas se usaron. |

Cada carpeta tiene su propio `README.md` con la descripción, los archivos modificados, cómo integrarlo con xv6 y la declaración de uso de IA.

---

# Estructura del repositorio

```text
oscraft/
├── README.md
├── Proyecto1/        shell para xv6
├── Proyecto2/        trace y sysinfo (xv6-riscv)
└── Proyecto3/        ugetpid, vmprint y pgaccess (xv6-riscv)
    ├── README.md
    ├── kernel/
    ├── user/
    └── pruebas/
```

En el Proyecto 3 solo se suben los archivos que se modificaron o crearon, con la misma ruta que tienen dentro de xv6. No se sube xv6 completo.
