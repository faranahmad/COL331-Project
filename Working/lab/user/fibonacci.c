#include <inc/lib.h>

void umain(int argc,char **argv)
{
	if(argc == 1)
	{
		panic("No args given");
	}
	char *ptr;
	long ret = strtol(argv[1],&ptr,10);
	int a = 1;
	int b = 1;
	int c;
	int i;
	int count=(int)ret;
	if(count==0 || count == 1)
	{
		cprintf("Fibonacci required: 1\n");
	}
	else
	{
		for(i=2;i<count+1;i++)
		{
			c = a+b;
			b = a;
			a = c;
		}
		cprintf("Fibonacci required: %d\n",c);
	}
}