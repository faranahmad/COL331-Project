#include <inc/lib.h>
#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/memlayout.h>


void umain(int argc,char **argv)
{
	// if(argc > 2)
	// {
	// 	cprintf("only one arguement allowed\n");
	// 	return;
	// }
	if(argc == 1)
	{
		cprintf("enter the arguement\n");
		return;
	}
	char *arg;
	arg = argv[1];
	cprintf("%s\n",arg);
	return;
}