#include <inc/lib.h>

void umain(int argc,char** argv)
{
	cprintf("I am in kill: %d\n",argc);
	if(argc > 1)
	{
		int i;
		char *ptr;
		long ret;
		for(i=1;i<argc;i++)
		{
			// cprintf("%s\n",argv[0]);
			ret = strtol(argv[i], &ptr, 10);
			envid_t envid = (envid_t)ret;
			sys_env_destroy(envid);
			
		}
	}
	else
	{
		envid_t envid;
		envid = sys_getenvid();
		sys_env_destroy(envid);
	}
}