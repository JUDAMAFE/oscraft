struct sysinfo {
  uint64 freemem;      // Memoria libre disponible (en bytes o MB)
  uint64 n_upages;     // Número de páginas utilizadas
  uint64 n_apages;     // Número de páginas disponibles
  uint64 n_runnable;   // Número de procesos en estado RUNNABLE
};