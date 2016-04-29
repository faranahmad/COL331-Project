#include <kern/UserProg.h>
#include <inc/stdio.h>
#include <inc/string.h>

void User_Echo(int argc, char** argv)
{
	int i;
	for(i = 1; i < argc; i++)
	{
	   cprintf("%s%s", argv[i], i+1 < argc ? " " : "\n");	
	}	
}