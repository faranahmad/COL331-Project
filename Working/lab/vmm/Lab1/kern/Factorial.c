#include <kern/UserProg.h>
#include <inc/stdio.h>
#include <inc/string.h>

int User_Factorial(int argc, char** argv)
{
	if(argc == 1)
	{
		cprintf("enter the argument\n");
		return 0;
	}
	char *ptr;
	long ret = strtol(argv[1],&ptr,10);
	int a = 1;
	int b;

	int count = (int)ret;
	int i;
	for(i=1;i<count+1;i++)
	{
		a = a*i;
	}
	cprintf("Factorial required: %d\n",a);
	return 0;
}