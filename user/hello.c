// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	cprintf("hello, world from hello .c \n");
	cprintf("argc %d\n",argc);
	// cprintf("i am environment %08x\n", thisenv->env_id);
}
