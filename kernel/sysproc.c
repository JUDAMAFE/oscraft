#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"
#include "../user/sysinfo.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if (t == SBRK_EAGER || n < 0) {
    if (growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
      return -1;
    if (addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    release(&tickslock);
    sleep();
    acquire(&tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_sysinfo(void)
{
  uint64 addr;
  struct sysinfo info;

  // 1. Extraemos la dirección de memoria virtual que pasó el usuario por argumento
  argaddr(0, &addr);

  // 2. Rellenamos los campos de la estructura con las funciones auxiliares del kernel
  info.n_runnable = get_runnable_count();        // Función que creamos en proc.c
  info.freemem = get_free_memory();              // Memoria libre en bytes
 // Calcular el total de páginas físicas reales restando KERNBASE a PHYSTOP
uint64 total_pages = (PHYSTOP - KERNBASE) / PGSIZE;
uint64 free_pages = info.freemem / PGSIZE;

// Asigna el resultado correcto a n_upages (Páginas usadas)
if (total_pages > free_pages) {
    info.n_upages = total_pages - free_pages;
} else {
    info.n_upages = 0;
}

// Y si necesitas guardar las disponibles o totales en n_apages:
info.n_apages = free_pages; // o el valor que corresponda según tu estructura
  
  // (Opcional según tu lógica: puedes calcular páginas usadas restando del total físico)

  // 3. Copiamos la estructura del kernel al espacio de usuario de forma segura con copyout
if (copyout(myproc()->pagetable, myproc()->sz, addr, (char *)&info, sizeof(info)) < 0)
    return -1;

  return 0;
}
