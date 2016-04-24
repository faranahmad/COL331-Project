// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

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
	// cprintf("Error Code: %d\n",err);
	if((err & FEC_WR) == 0){
		panic("Fault not caused by write");
	}
	pte_t pte = uvpt[PGNUM(ROUNDDOWN(addr,PGSIZE))];
	if((pte & PTE_COW) == 0){
		panic("Page not copy on write");
	}

	addr = (void*)ROUNDDOWN((uintptr_t)addr,PGSIZE);
	// cprintf("Print id: %d\n",thisenv -> env_id);
	if((r = sys_page_alloc(sys_getenvid(),(void*)PFTEMP,PTE_P|PTE_U|PTE_W))< 0){
		panic("Page can't be allocated");
	}
	// if((r = sys_page_map(0,addr,0,(void*)PFTEMP,PTE_P|PTE_U|PTE_W)) < 0){
	// 	panic("Temp page can't be mapped");
	// }
	// // cprintf("I am here\n");
	memmove((void*)PFTEMP,addr,PGSIZE);
	if((r = sys_page_map(sys_getenvid(),(void*)PFTEMP,sys_getenvid(),addr,PTE_P|PTE_U|PTE_W)) < 0){
		panic("Temp page can't be mapped");
	}
	if(sys_page_unmap(sys_getenvid(),PFTEMP) < 0){
		panic("sys_page_unmap");
	}
	// if((r = sys_page_unmap(thisenv -> env_id,(void*)PFTEMP)) < 0){
	// 	panic("Unable to unmap page");
	// }

	// LAB 4: Your code here.

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

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

static int
duppage(envid_t envid, unsigned pn)
{

	int r;
	void* va = (void*)(pn*PGSIZE);
	// cprintf("In dup page\n");

	pte_t pte = uvpt[pn];
	if((pte & PTE_W) || (pte & PTE_COW)){// page is writable or copy-on-write)
		if((r = sys_page_map(sys_getenvid(),va,envid,va,PTE_COW | PTE_P | PTE_U)) < 0){
			panic("Mapping failed");
		}
		if((r = sys_page_map(sys_getenvid(),va,sys_getenvid(),va,PTE_COW | PTE_P | PTE_U)) < 0){
			panic("Can't set parent page perm");
		}
	}
	else{
		if((r = sys_page_map(sys_getenvid(),va,envid,va,PTE_P | PTE_U)) < 0){
			panic("Can't map other page");
		}
	}
	// cprintf("Duppage done\n");

	return 0;
	// LAB 4: Your code here.

	// return 0;
	// panic("duppage not implemented");
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

	set_pgfault_handler(pgfault);
	// cprintf("Starting fork\n");
	// cprintf("id: %d\n",present_id);

	envid_t child;
	if((child = sys_exofork()) < 0){
		panic("Child not forkded");
	}
	if(child == 0){
		// cprintf("id; %d\n",sys_getenvid());
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	uint32_t pn;
	pte_t *pte;
	for (pn = 0; pn < PGNUM(UTOP); pn++) {

		if ((uvpd[PDX(pn*PGSIZE)] & PTE_P)==0) 
			continue;
		
		if ((uvpt[pn] & PTE_P)==0) 
			continue;


		if (pn*PGSIZE != UXSTACKTOP - PGSIZE)
			duppage(child, pn);
	}
	// cprintf("Main part done\n");
	int r;
	if((r = sys_page_alloc(child,(void*)(UXSTACKTOP - PGSIZE),PTE_P | PTE_W | PTE_U)) < 0){
		panic("Can't allocate new page for exception stack");
	}

	// if((r = sys_page_map(child,(void*)(UXSTACKTOP - PGSIZE),sys_getenvid(),(void*)PFTEMP,PTE_P|PTE_W|PTE_U)) < 0){
	// 	panic("Mapping to temp page failed");
	// }
	// memcpy((void*)(UXSTACKTOP - PGSIZE),(void*)PFTEMP, PGSIZE);
	// if((r = sys_page_unmap(child,(void*)PFTEMP)) < 0){
	// 	panic("Unable to unmap");
	// }

	if((r = sys_env_set_pgfault_upcall(child,thisenv -> env_pgfault_upcall)) < 0){
		panic("Unable to set pg fault upcall");
	}

	if((r = sys_env_set_status(child,ENV_RUNNABLE)) < 0){
		panic("Unable to set status Runnable");
	}
	// cprintf("Done fork\n");
	return child;
}



// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
