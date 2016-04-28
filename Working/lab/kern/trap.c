#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>

static struct Taskstate ts;

/* For debugging, so print_trapframe can distinguish between printing
 * a saved trapframe and printing the current trapframe and print some
 * additional information in the latter case.
 */
static struct Trapframe *last_tf;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = { { 0 } };
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t) idt
};


static const char *trapname(int trapno)
{
	static const char * const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
}


void
trap_init(void)
{
	extern struct Segdesc gdt[];
	extern int table[];
	int* table1 = table;

	// LAB 3: Your code here.
	// extern void divide();
	// extern void debug();
	// extern void nmi();
	extern void brkpt();
	// extern void oflow();
	// extern void mybound();
	// extern void illop();
	// // extern void device();
	// extern void dblflt();
	// extern void tss();
	// extern void segnp();
	// extern void stack();
	// extern void gpflt();
	// extern void pgflt();
	// extern void fperr();
	// extern void align();
	// extern void mchk();
	// extern void simderr();
	extern void irq_timer();
	extern void irq_kbd();
	extern void irq_serial();
	extern void irq_spurious();
	extern void irq_ide();
	extern void irq_error();
	extern void mysyscall();
	extern void mydefault();
	int i;
	for(i=0;i<256;i++)
	{
		if(*table1 == i)
		{
			// cprintf("Value of i: %d\n",i);
			SETGATE(idt[i],0,GD_KT,*(table1+1),0);
			table1 += 2;
		}
		else
		{
			SETGATE(idt[i],0,GD_KT,mydefault,0);
		}
	}
	SETGATE(idt[T_BRKPT],0,GD_KT,brkpt,3);
	SETGATE(idt[T_SYSCALL],0,GD_KT,mysyscall,3);
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,irq_timer,0);
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,irq_kbd,0);
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL],0,GD_KT,irq_serial,0);
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS],0,GD_KT,irq_spurious,0);
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE],0,GD_KT,irq_ide,0);
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR],0,GD_KT,irq_error,0);



	// see what to do with istrap
	// SETGATE(idt[T_DIVIDE],1,GD_KT,divide,0);
	// SETGATE(idt[T_DEBUG],1,GD_KT,debug,0);
	// SETGATE(idt[T_NMI],1,GD_KT,nmi,0);
	// SETGATE(idt[T_BRKPT],1,GD_KT,brkpt,3);
	// SETGATE(idt[T_OFLOW],1,GD_KT,oflow,0);
	// SETGATE(idt[T_BOUND],1,GD_KT,mybound,0);
	// SETGATE(idt[T_ILLOP],1,GD_KT,illop,0);
	// // SETGATE(idt[T_DEVICE],1,GD_KT,device,0);
	// SETGATE(idt[T_DBLFLT],1,GD_KT,dblflt,0);
	// SETGATE(idt[T_TSS],1,GD_KT,tss,0);
	// SETGATE(idt[T_SEGNP],1,GD_KT,segnp,0);
	// SETGATE(idt[T_STACK],1,GD_KT,stack,0);
	// SETGATE(idt[T_GPFLT],1,GD_KT,gpflt,0);
	// SETGATE(idt[T_PGFLT],1,GD_KT,pgflt,0);
	// SETGATE(idt[T_FPERR],1,GD_KT,fperr,0);
	// SETGATE(idt[T_ALIGN],1,GD_KT,align,0);
	// SETGATE(idt[T_MCHK],1,GD_KT,mchk,0);
	// SETGATE(idt[T_SIMDERR],1,GD_KT,simderr,0);
	// SETGATE(idt[T_SYSCALL],1,GD_KT,mysyscall,3);
	// SETGATE(idt[T_DEFAULT],1,GD_KT,mydefault,0);

	// Per-CPU setup 
	trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
	// The example code here sets up the Task State Segment (TSS) and
	// the TSS descriptor for CPU 0. But it is incorrect if we are
	// running on other CPUs because each CPU has its own kernel stack.
	// Fix the code so that it works for all CPUs.
	//
	// Hints:
	//   - The macro "thiscpu" always refers to the current CPU's
	//     struct CpuInfo;
	//   - The ID of the current CPU is given by cpunum() or
	//     thiscpu->cpu_id;
	//   - Use "thiscpu->cpu_ts" as the TSS for the current CPU,
	//     rather than the global "ts" variable;
	//   - Use gdt[(GD_TSS0 >> 3) + i] for CPU i's TSS descriptor;
	//   - You mapped the per-CPU kernel stacks in mem_init_mp()
	//
	// ltr sets a 'busy' flag in the TSS selector, so if you
	// accidentally load the same TSS on more than one CPU, you'll
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	int i = thiscpu -> cpu_id;  // gives the id of cpu
	thiscpu -> cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
	thiscpu -> cpu_ts.ts_ss0 = GD_KD;

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t) (&thiscpu -> cpu_ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	// cprintf("Cpu_id: %d\n",i);
	ltr(GD_TSS0 + (i << 3));		

	// Load the IDT
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0) {
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void
print_regs(struct PushRegs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

static void
trap_dispatch(struct Trapframe *tf)
{






	if (curenv->env_type == ENV_TYPE_GUEST)
	{
		// unsigned int mask = (1<<31);
		// mask -=1;
		// mask = (mask >>2);
		// mask = (mask <<2);
		// print_trapframe(tf);
		// curenv->env_tf.tf_cs &= mask;
		// lcr3(PADDR(curenv->env_pgdir));
		// cprintf("It is guest thingy, need to handle %d , eip is %08x, command is %08x, cs is %d\n", tf->tf_trapno,  curenv->env_tf.tf_eip,*(uint32_t *) (0*curenv->env_tf.tf_cs + curenv->env_tf.tf_eip), curenv->env_tf.tf_cs);
		if (*(uint8_t *) (0*curenv->env_tf.tf_cs + curenv->env_tf.tf_eip) == 0xfa)
		{
			cprintf("This is cli instruction, have to jump to kernel now\n");
			// tf->tf_eflags &= ~FL_IF;
			// curenv->env_tf.tf_eip =  (uint32_t) (((uint8_t*) curenv->env_tf.tf_eip)	+ 1);
			
			// Jumping to kernel
			curenv->env_tf.tf_eip =  0x00100000;
			
			cprintf("Final eip %08x \n", curenv->env_tf.tf_eip);
			return;
		}
		else if (*(uint8_t *) (0*curenv->env_tf.tf_cs + curenv->env_tf.tf_eip) == 0xec)
		{
			if (curenv->env_tf.tf_eip==0x1001d9)
			{
				// cprintf("Triggered by the command\n");
			}
			// cprintf("This is in\n");
			int val = curenv->env_tf.tf_regs.reg_edx;
			// int vala = curenv->env_tf.tf_regs.reg_eax;
			
			// int temp;
			// asm volatile("pushal \n");
			// asm volatile("in (%%dx), %%al\n"
			// 	: "=a" (temp)
			// 	: "d" (val)
			// 	: "cc", "memory"
			// 	);
			// // asm volatile("in (%%edx) %%al \n");
			// // asm volatile("movl %%eax, %0\n"
			// 	// : "=b" (temp)
			// 	// : 
			// 	// : "cc", "memory"
			// 	// );
			// asm volatile("popal \n");
			// if (temp)
			// {	
			// 	cprintf("YAYAYAYAYAYAAYAYAYAYAY Temp obtained is %d\n",temp);
			// }
			// cprintf("val %d\n",val);
			curenv->env_tf.tf_regs.reg_eax = inb(val);
			// curenv->env_tf.tf_regs.reg_eax = getchar_unlocked();
				// "popal \n\t"
				// );
			// tf->tf_eflags &= ~FL_IF;

			curenv->env_tf.tf_eip =  (uint32_t) (((uint8_t*) curenv->env_tf.tf_eip)	+ 1);
			// curenv->env_tf.tf_eip =  0x00100000;
			
			// cprintf("Final eip %08x \n", curenv->env_tf.tf_eip);
			return;
		}
		else if (*(uint8_t *) (0*curenv->env_tf.tf_cs + curenv->env_tf.tf_eip) == 0xee)
		{
			// cprintf("This is out\n");
			int val = curenv->env_tf.tf_regs.reg_eax;
			int temp = curenv->env_tf.tf_regs.reg_edx;
			// int temp1;
			// asm volatile("pushal \n");
			// asm volatile("out %%al, (%%dx)\n"
			// 	: "=d" (temp1)
			// 	: "a" (val) ,
			// 	  "d" (temp)
			// 	: "cc", "memory"
			// 	);
			// // asm volatile("in (%%edx) %%al \n");
			// // asm volatile("movl %%eax, %0\n"
			// 	// : "=b" (temp)
			// 	// : 
			// 	// : "cc", "memory"
			// 	// );
			// asm volatile("popal \n");
			// outb(temp,val);
			// outb(,val);
			if (((val>=32) && (val<128)) || (val==10))
			{
				if (curenv->env_tf.tf_eip %2 ==1)
				{
					// char x = (char) val;
					cputchar(val);
				}
			// 	// cprintf(" yo %c %08x\n",x, curenv->env_tf.tf_eip);
			}
			// cprintf(" %d %d \n",val,*(uint32_t*)temp);
			// *(uint32_t *) (curenv->env_tf.tf_regs.reg_edx) = temp;
				// "popal \n\t"
				// );
			// tf->tf_eflags &= ~FL_IF;

			curenv->env_tf.tf_eip =  (uint32_t) (((uint8_t*) curenv->env_tf.tf_eip)	+ 1);
			// curenv->env_tf.tf_eip =  0x00100000;
			
			// cprintf("Final eip %08x \n", curenv->env_tf.tf_eip);
			return;
		}
		else if  (*(uint16_t *) (0*curenv->env_tf.tf_cs + curenv->env_tf.tf_eip) == 0xd08e)
		{
			// curenv->env_tf.tf_ss = curenv->env_tf.tf_regs.reg_eax;
			curenv->env_tf.tf_eip =  (uint32_t) (((uint16_t*) curenv->env_tf.tf_eip)	+ 1);
			cprintf("Final eip %08x \n", curenv->env_tf.tf_eip);
			return;	
		}
		else if  (*(uint32_t *) (0*curenv->env_tf.tf_cs + curenv->env_tf.tf_eip) == 0x0dc0200f)
		{
			cprintf("In this thingy\n");
			cprintf("It is guest thingy, need to handle %d , eip is %08x, command is %08x, cs is %d\n", tf->tf_trapno,  curenv->env_tf.tf_eip,*(uint32_t *) (0*curenv->env_tf.tf_cs + curenv->env_tf.tf_eip), curenv->env_tf.tf_cs);
		
			curenv->env_tf.tf_eip =  0x00100028;
			return;
			// curenv->env_tf.tf_cs = 
		}
		// else
		// {
		// 	cprintf("Destroying env\n");
		// 	env_destroy(curenv);
		// 	return;
		// }
		// cprintf("It is guest thingy, need to handle %d , eip is %08x, command is %08x, cs is %d\n", tf->tf_trapno,  curenv->env_tf.tf_eip,*(uint32_t *) (0*curenv->env_tf.tf_cs + curenv->env_tf.tf_eip), curenv->env_tf.tf_cs);
				
		// curenv->env_tf.tf_eip+=1;
		// lcr3(PADDR(kern_pgdir));
		// return;
	}





	// Handle processor exceptions.
	// LAB 3: Your code here.
	// cprintf("Trap no.: %d\n",tf->tf_trapno);
	switch(tf->tf_trapno)
	{
		case T_DEBUG:
			tf->tf_eflags |= -FL_TF;
			break;
		case T_PGFLT:
			page_fault_handler(tf);
			break;
		case T_BRKPT:
			monitor(tf);
			break;
		case T_SYSCALL:
			tf->tf_regs.reg_eax =  syscall(tf->tf_regs.reg_eax,tf->tf_regs.reg_edx,tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx,tf->tf_regs.reg_edi,tf->tf_regs.reg_esi);
			// cprintf("Env final: %08x\n",tf->tf_regs.reg_eax);
			return;
		default:
			break;
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
		cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
		return;
	}
	else if(tf->tf_trapno==33)
	{
		// cprintf("In keyboard interrupt case\n");
		kbd_intr();
		// tf->tf_regs.reg_eax = cons_getc();
		return;
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER){
		lapic_eoi();
		sched_yield();
	}
	// Unexpected trap: The user process or the kernel has a bug.
	if (curenv->env_type==ENV_TYPE_GUEST)
	{
		cprintf("Destroying env\n");
		env_destroy(curenv);
		return;		
	}

	// cprintf("i m here\n");
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else {
		cprintf("Destroying env\n");
		env_destroy(curenv);
		return;
	}
}

void
trap(struct Trapframe *tf)
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
		asm volatile("hlt");

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

	if ((tf->tf_cs & 3) == 3) {
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
			env_free(curenv);
			curenv = NULL;
			sched_yield();
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
	{
		// cprintf("i am in trap\n");
		env_run(curenv);
		
	}
	else
		sched_yield();
}


void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
	// cprintf("Faulting va: %0x\n",fault_va);

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// cprintf("tf->cs:%08x\t %08x\n",tf->tf_cs, tf->tf_cs & 0x3);
	if((tf->tf_cs & 0x3) != 3){
		panic("Page fault occured in kernel mode\n");
	}
	// cprintf("tf->cs : %08x\n",(tf->tf_cs & 00));

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.
	if(curenv -> env_pgfault_upcall != 0 && (tf->tf_esp >= UXSTACKTOP - PGSIZE || tf-> tf_esp < USTACKTOP)){
		// user_mem_assert(curenv, curenv -> env_pgfault_upcall, 0, PTE_U | PTE_P);

		uintptr_t my_stack;
		if(tf -> tf_esp >= UXSTACKTOP - PGSIZE && tf -> tf_esp <= UXSTACKTOP - 1){
			my_stack = tf -> tf_esp - 4;
		}
		else{
			my_stack = UXSTACKTOP;
		}
		// cprintf("I am here\n");

		struct UTrapframe* user_tf;
		if((my_stack - sizeof(struct UTrapframe)) < UXSTACKTOP - PGSIZE){
			// cprintf("I am here\n");
			goto destroy;
		}
		user_tf = (struct UTrapframe*)(my_stack - sizeof(struct UTrapframe));
		user_mem_assert(curenv,(void*)user_tf,1,PTE_W);
		user_tf -> utf_fault_va = fault_va;
		user_tf -> utf_err = tf-> tf_err;
		user_tf -> utf_regs = tf-> tf_regs;
		user_tf -> utf_eip = tf-> tf_eip;
		user_tf -> utf_eflags = tf-> tf_eflags;
		user_tf -> utf_esp = tf-> tf_esp;

		tf-> tf_esp = (uintptr_t)user_tf;
		tf-> tf_eip = (uintptr_t)curenv -> env_pgfault_upcall;
		env_run(curenv);
	}
	else{
		goto destroy;
		
	}

	destroy:
		cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
		print_trapframe(tf);
		env_destroy(curenv);
	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// The trap handler needs one word of scratch space at the top of the
	// trap-time stack in order to return.  In the non-recursive case, we
	// don't have to worry about this because the top of the regular user
	// stack is free.  In the recursive case, this means we have to leave
	// an extra word between the current top of the exception stack and
	// the new stack frame because the exception stack _is_ the trap-time
	// stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack or can't write to it, or the exception
	// stack overflows, then destroy the environment that caused the fault.
	// Note that the grade script assumes you will first check for the page
	// fault upcall and print the "user fault va" message below if there is
	// none.  The remaining three checks can be combined into a single test.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	
}

