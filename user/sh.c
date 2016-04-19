#include <inc/lib.h>
#include <inc/stdio.h>
#include <inc/error.h>
#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

// #define UTEMP2USTACK(addr)	((void*) (addr) + (USTACKTOP - PGSIZE) - UTEMP)

char y1[2][1024]; 

int CheckAnd(char* inp)
{
	int i;
	for (i=strlen(inp)-1; i>=0; i--)
	{
		if (inp[i]=='&')
		{
			return 1;
		}
		else if (inp[i]==' ')
		{

		}
		else
		{
			return 0;
		}
	}
	return 0;
}


int GetSz(char* inp)
{
	int ans=0;
	int i;
	for (i=0;i<strlen(inp);i++)
	{
		if ((inp[i]==' ') || (inp[i]=='\t'))
		{
			ans+=1;
		}
	}
	if (CheckAnd(inp))
	{
		ans-=1;
	}
	return ans+1;
}


int GetSize(char* inp)
{
	int ans=0;
	int i;
	for (i=0;i<strlen(inp);i++)
	{
		if ((inp[i]==' ') || (inp[i]=='\t'))
		{
			ans+=1;
		}
	}
	if (ans==0)
	{	
		return 1;
	}
	return 2;
}

int ParseLine(char* inp, char parsed[2][1024])
{
	int size = GetSize(inp);
	// parsed =(char**) malloc(size*(sizeof (char*)));


	int present, start,end,i,j;

	for (i=0; i<2;i++)
	{
		for (j=0;j<1024;j++)
		{
			parsed[i][j]='\0';
		}
	}

	start=0;
	present=0;
	end=0;
	for (i=0;i<strlen(inp) && (present ==0);i++)
	{
		if ((inp[i]==' ') ||(inp[i]=='\t') ||(inp[i]=='\n'))
		{
			// parsed[i]=(char*) malloc(sizeof(char)*(1+end-start));
			int j=start;
			for(;j<end;j++)
			{
				parsed[present][j-start]=inp[j];
			}
			// parsed[present][end-start]='\0';
			// copy parsed
			present++; 
			start = end+1;
		}
		end++;	
	}
	j=start;
	for (j=start;j<strlen(inp);j++)
	{
		parsed[size-1][j-start]=inp[j];
	}

	i=size-1;
	for (j=1023;j>=0;j--)
	{
		if (parsed[i][j]=='&')
		{
			parsed[i][j]='\0';	
		}
		else if ((parsed[i][j]=='\0')||(parsed[i][j]==' '))
		{

		}
		else
		{
			break;
		}
	}

	return size;
}

void
umain(int argc, char **argv)
{
	// char exitc[5]= "exit";
	// char calender[12]= "cal";
	// char factorial[12]= "factorial";
	// char fibonacci[12]= "fibonacci";
	// char date[12]= "date";
	// char echostr[6] = "faran";



	// char* h1 = "hello";
	// char* h2 = "world";

	// uintptr_t * argvst;
	// Commands = 
	// cprintf("hello, world\n");
	// cprintf("hello, world kg\n");
	char *buf;
	int needbackground= 0;
	cprintf("Starting shell with pid = %d  \n", thisenv->env_id);
	// char y1[16][16]; 
	buf = readline("!>");
	needbackground = CheckAnd(buf);
	int x1= ParseLine(buf,y1);
	int actsz = GetSz(buf);
	int l;


	// for (l=0;l<2;l++)
	// {
	// 	cprintf("%d %s\n",l,y1[l]);
	// }
	// cprintf("parsed\n");


	while (strcmp(y1[0],"exit")!=0)
	{
		if (strcmp(y1[0],"factorial")==0)
		{
			int x = fork();
			if (x==0)
			{
				cprintf("In child with pid = %d and parent id = %d \n", thisenv->env_id, thisenv->env_parent_id);
				char* stringst;
				size_t string_size = 0;
				int i; 
				for (i=0;i<x1;i++)
				{
					// string_size += 1 + strlen(y1[0]);
					string_size += 1025;
				}
				// hello world
				stringst = (char*) UTEMP + PGSIZE - string_size;
				// argvst = (uintptr_t*) (ROUNDDOWN(stringst,4) -4* (3));
				int r;
				r = sys_page_alloc(thisenv->env_id,(void*) UTEMP, PTE_P|PTE_U|PTE_W);
				if (r<0)
				{
					panic("page alloc failed\n");
				}
				uintptr_t argvst[x1];

				for (i=0;i<x1;i++)
				{
					argvst[i]= (uintptr_t) stringst;
					strcpy(stringst,y1[i]);
					// stringst+= 1+ strlen(y1[i]);
					stringst+=1025;					
				}
				sys_envreplace(1,(void*) argvst,actsz);
			}
			else
			{
				if (needbackground==0)
					wait(x);
			}
		}
		else if (strcmp(y1[0],"echo")==0)
		{
			// cprintf("Echo about to fork\n");
			int x= fork();
			if (x==0)
			{

				cprintf("In child with pid = %d and parent id = %d \n", thisenv->env_id, thisenv->env_parent_id);
				// cprintf("Reached this place\n");
				char* stringst;
				size_t string_size = 0;
				int i; 
				for (i=0;i<x1;i++)
				{
					// string_size += 1 + strlen(y1[0]);
					string_size += 1025;
				}
				// hello world
				stringst = (char*) UTEMP + PGSIZE - string_size;
				// argvst = (uintptr_t*) (ROUNDDOWN(stringst,4) -4* (2));
				int r;

				// cprintf("Reached this place as well\n");
				r = sys_page_alloc(thisenv->env_id,(void*) UTEMP, PTE_P|PTE_U|PTE_W);
				if (r<0)
				{
					panic("page alloc failed\n");
				}

				// cprintf("Reached this place as well dude\n");
				
				uintptr_t argvst[x1];

				// cprintf("Reached this place as well dude max\n");

				for (i=0;i<x1;i++)
				{
					argvst[i]= (uintptr_t) stringst;
					strcpy(stringst,y1[i]);
					// stringst+= 1+ strlen(y1[i]);
					stringst += 1025;
					// cprintf("Completed copying %d , stsize %d \n", i , stringst);
				}
				// cprintf("Reached this place as well man\n");
				
				sys_envreplace(5,(void*) argvst,actsz);
			}
			else
			{
				if (needbackground==0)
					wait(x);
			}
		}
		else if (strcmp(y1[0],"fibonacci")==0)
		{
			int x= fork();
			if (x==0)
			{

				cprintf("In child with pid = %d and parent id = %d \n", thisenv->env_id, thisenv->env_parent_id);
				char* stringst;
				size_t string_size = 0;
				int i; 
				for (i=0;i<x1;i++)
				{
					// string_size += 1 + strlen(y1[0]);
					string_size += 1025;
				}
				// hello world
				stringst = (char*) UTEMP + PGSIZE - string_size;
				// argvst = (uintptr_t*) (ROUNDDOWN(stringst,4) -4* (3));
				int r;
				r = sys_page_alloc(thisenv->env_id,(void*) UTEMP, PTE_P|PTE_U|PTE_W);
				if (r<0)
				{
					panic("page alloc failed\n");
				}
				uintptr_t argvst[x1];

				for (i=0;i<x1;i++)
				{
					argvst[i]= (uintptr_t) stringst;
					strcpy(stringst,y1[i]);
					// stringst+= 1+ strlen(y1[i]);
					stringst+=1025;
				}
				sys_envreplace(2,(void*) argvst,actsz);
			}
			else
			{
				if (needbackground==0)
					wait(x);
			}
		}
		else if (strcmp(y1[0],"date")==0)
		{
			int x = fork();
			if (x==0)
			{
				cprintf("In child with pid = %d and parent id = %d \n", thisenv->env_id, thisenv->env_parent_id);
				char* stringst;
				size_t string_size = 0;
				int i; 
				for (i=0;i<x1;i++)
				{
					// string_size += 1 + strlen(y1[0]);
					string_size += 1025;
				}
				// hello world
				stringst = (char*) UTEMP + PGSIZE - string_size;
				// argvst = (uintptr_t*) (ROUNDDOWN(stringst,4) -4* (3));
				int r;
				r = sys_page_alloc(thisenv->env_id,(void*) UTEMP, PTE_P|PTE_U|PTE_W);
				if (r<0)
				{
					panic("page alloc failed\n");
				}
				uintptr_t argvst[x1];

				for (i=0;i<x1;i++)
				{
					argvst[i]= (uintptr_t) stringst;
					strcpy(stringst,y1[i]);
					// stringst+= 1+ strlen(y1[i]);
					stringst+=1025;
				}
				sys_envreplace(3,(void*) argvst,actsz);
			}
			else
			{
				if (needbackground==0)
					wait(x);
			}
		}
		else if (strcmp(y1[0],"cal")==0)
		{
			int x = fork();
			if (x==0)
			{
				cprintf("In child with pid = %d and parent id = %d \n", thisenv->env_id, thisenv->env_parent_id);
				// cprintf("My env id is %d\n", thisenv->env_id);
				char* stringst;
				size_t string_size = 0;
				int i; 
				for (i=0;i<x1;i++)
				{
					// string_size += 1 + strlen(y1[0]);
					string_size += 1025;
				}
				// hello world
				stringst = (char*) UTEMP + PGSIZE - string_size;
				// argvst = (uintptr_t*) (ROUNDDOWN(stringst,4) -4* (3));
				int r;
				r = sys_page_alloc(thisenv->env_id,(void*) UTEMP, PTE_P|PTE_U|PTE_W);
				if (r<0)
				{
					panic("page alloc failed\n");
				}
				uintptr_t argvst[x1];

				for (i=0;i<x1;i++)			
				{
					argvst[i]= (uintptr_t) stringst;
					strcpy(stringst,y1[i]);
					// stringst+= 1+ strlen(y1[i]);
					stringst+=1025;
				}
				sys_envreplace(4,(void*) argvst,actsz);
			}
			else
			{
				if (needbackground==0)
					wait(x);
			}
		}
		buf = readline("!>");
		needbackground = CheckAnd(buf);
		x1= ParseLine(buf,y1);
		actsz = GetSz(buf);
	}
	cprintf("Exiting shell, Goodbye\n");
}
