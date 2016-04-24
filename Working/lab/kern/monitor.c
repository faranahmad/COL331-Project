// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display the trace of the stack", mon_backtrace}//,
	// { "continue", "Continue further instructions", mon_continue},
	// { "step", "step through instructions", mon_step}
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t eip;
	__asm__ volatile("movl $., %0" : "=r"(eip));
	cprintf("Stack backtrace:\n");
	struct Eipdebuginfo inf;
	int m = debuginfo_eip(eip,&inf);
	cprintf("  current eip=%x\n",eip);
	cprintf("\t%s:%d: %.*s+%d\n",inf.eip_file,inf.eip_line,inf.eip_fn_namelen,inf.eip_fn_name,eip - inf.eip_fn_addr);
	uint32_t *ebp = (uint32_t*)read_ebp();

	while(ebp != 0x0)
	{
		struct Eipdebuginfo info;
		uintptr_t ra = ebp[1];
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n",ebp,ebp[1],ebp[2],ebp[3],ebp[4],ebp[5],ebp[6]);
		int c = debuginfo_eip(ra,&info);
		uintptr_t fn_addr = info.eip_fn_addr;
		int bytes = ra-fn_addr;
		cprintf("\t%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,bytes);
		ebp = (uint32_t*)(*ebp);
	}
	return 0;
}

// int
// cont_further(int argc,char **argv, struct Trapframe *tf,int step)
// {
// 	if((tf == NULL) || !((tf->tf_trapno == T_BRKPT) || (tf->tf_trapno == T_DEBUG)))
// 	{
// 		// cprintf("here i am\n");
// 		return 0;
// 	}
// 	if(step == 1)
// 	{
// 		// cprintf("here\n");
// 		tf->tf_eflags |= FL_TF;
// 	}
// 	return -1;
// }

// int mon_step(int argc,char **argv, struct Trapframe *tf)
// {
// 	return cont_further(argc,argv,tf,1);
// }

// int mon_continue(int argc,char **argv, struct Trapframe *tf)
// {
// 	return cont_further(argc,argv,tf,0);
// }

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			{
				cprintf("in runcmd\n");
				return commands[i].func(argc, argv, tf);
			}
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);


	// cprintf("%d\n",tf->tf_eflags);
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
