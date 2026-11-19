// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

// Conteo de referencias por página física entre KERNBASE y PHYSTOP.
// Tiene su propio lock; nunca se toma junto con kmem.lock.
#define NPAGINAS ((PHYSTOP - KERNBASE) / PGSIZE)
struct {
  struct spinlock lock;
  int cuenta[NPAGINAS];
} refs;

#define IDX(pa) (((uint64)(pa) - KERNBASE) / PGSIZE)

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  initlock(&refs.lock, "refs");
  freerange(end, (void *)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char *)PGROUNDUP((uint64)pa_start);
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE) {
    // Estas páginas nunca pasaron por kalloc(): se les da 1 referencia
    // para que kfree() la baje a 0 y la deje en la lista libre.
    refs.cuenta[IDX(p)] = 1;
    kfree(p);
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Solo la última referencia libera la página.
  acquire(&refs.lock);
  if (refs.cuenta[IDX(pa)] < 1)
    panic("kfree: refcount");
  int quedan = --refs.cuenta[IDX(pa)];
  release(&refs.lock);
  if (quedan > 0)
    return;

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run *)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if (r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if (r) {
    acquire(&refs.lock);
    refs.cuenta[IDX(r)] = 1;
    release(&refs.lock);
    memset((char *)r, 5, PGSIZE); // fill with junk
  }
  return (void *)r;
}

// Agrega una referencia a la página física pa (ya asignada).
void
krefinc(void *pa)
{
  acquire(&refs.lock);
  if (refs.cuenta[IDX(pa)] < 1)
    panic("krefinc");
  refs.cuenta[IDX(pa)]++;
  release(&refs.lock);
}

// Número de referencias de la página física pa.
int
krefcount(void *pa)
{
  acquire(&refs.lock);
  int n = refs.cuenta[IDX(pa)];
  release(&refs.lock);
  return n;
}

// Páginas físicas en la lista libre.
uint64
kfreepages(void)
{
  uint64 n = 0;
  acquire(&kmem.lock);
  for (struct run *r = kmem.freelist; r; r = r->next)
    n++;
  release(&kmem.lock);
  return n;
}

// Páginas físicas con más de una referencia.
uint64
ksharedpages(void)
{
  uint64 n = 0;
  acquire(&refs.lock);
  for (int i = 0; i < NPAGINAS; i++)
    if (refs.cuenta[i] > 1)
      n++;
  release(&refs.lock);
  return n;
}
