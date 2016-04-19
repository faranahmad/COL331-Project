// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

extern void _pgfault_upcall(void);

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR)==0)
	{
		panic("Address is not a write\n");
	}


	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r= sys_page_alloc(0,PFTEMP,PTE_P|PTE_U|PTE_W);
	void* srcaddr = (void*) ROUNDDOWN(addr,PGSIZE);
	memmove(PFTEMP,(void*) srcaddr,PGSIZE);

	r=sys_page_map(0,PFTEMP,0,(void*) srcaddr, PTE_P|PTE_U|PTE_W );

	// panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	if(uvpt[pn] & PTE_COW)
	{
		if (uvpt[pn] & PTE_U)
		{
			r= sys_page_map(thisenv->env_id,(void*) (pn*PGSIZE), envid, (void*) (pn*PGSIZE),(PTE_P|PTE_COW|PTE_U));
			r= sys_page_map(thisenv->env_id,(void*) (pn*PGSIZE), thisenv->env_id, (void*) (pn*PGSIZE),(PTE_P|PTE_COW|PTE_U));
		}
		else
		{
			r= sys_page_map(thisenv->env_id,(void*) (pn*PGSIZE), envid, (void*) (pn*PGSIZE),(PTE_P|PTE_COW));
			r= sys_page_map(thisenv->env_id,(void*) (pn*PGSIZE), thisenv->env_id, (void*) (pn*PGSIZE),(PTE_P|PTE_COW));
		}
	}
	else if (uvpt[pn] & PTE_W)
	{
		if (uvpt[pn] & PTE_U)
		{
			r= sys_page_map(thisenv->env_id,(void*) (pn*PGSIZE), envid, (void*) (pn*PGSIZE),(PTE_P|PTE_COW|PTE_U));			
			r= sys_page_map(thisenv->env_id,(void*) (pn*PGSIZE), thisenv->env_id, (void*) (pn*PGSIZE),(PTE_P|PTE_COW|PTE_U));
		}
		else
		{
			r= sys_page_map(thisenv->env_id,(void*) (pn*PGSIZE), envid, (void*) (pn*PGSIZE),(PTE_P|PTE_COW));
			r= sys_page_map(thisenv->env_id,(void*) (pn*PGSIZE), thisenv->env_id, (void*) (pn*PGSIZE),(PTE_P|PTE_COW));
		}
	}
	else
	{
		r= sys_page_map(thisenv->env_id, (void*) (pn*PGSIZE), envid, (void*) (pn*PGSIZE), uvpt[pn]&0xFFF);
	}


	// panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	// panic("fork not implemented");
	int x;
	set_pgfault_handler(pgfault);

	envid_t child = sys_exofork();
	if (child==0)
	{
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	else
	{
		int y;
		for (y=0; y< PGNUM(UTOP-PGSIZE); y++)
		{
			int temp = ROUNDDOWN(y,NPDENTRIES) / NPDENTRIES;
			if ((uvpd[temp] & PTE_P) == PTE_P)
			{
				if ((uvpt[y] & PTE_P)== PTE_P)
				{
					duppage(child,y);
				}
			}
		}
		x= sys_page_alloc(child,(void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
		x= sys_env_set_pgfault_upcall(child,_pgfault_upcall);
		x= sys_env_set_status(child,ENV_RUNNABLE);
		return child;
	}
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
