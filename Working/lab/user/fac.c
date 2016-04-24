#include <inc/lib.h>

void umain(int argc,char **argv)
{
	cprintf("here\n");
	// if(argc == 1)
	// {
	// 	panic("No arg given");
	// }
	char *ptr;
	// long ret = strtol(argv[1],&ptr,10);
	int ret = 3;
	int a = 1;
	int b;

	int count = (int)ret;
	int i;
	for(i=1;i<=count;i++)
	{
		a = a*i;
	}
	cprintf("Factorial required: %d\n",a);
}