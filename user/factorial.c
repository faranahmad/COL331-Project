// #include <stdio.h>
#include <inc/string.h>
#include <inc/lib.h>
#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/memlayout.h>



int checkInt(char* inp)
{
	int i=0;
	for (;i<strlen(inp);i++)
	{
		if ((inp[i]<'0') || (inp[i]>'9'))
		{
			if (inp[i]!=32)
				return 0;
		}
	}
	return 1;
}


long fact(long n)
{
	long i = 1;
	long ans = 1;
	for(;i<=n;i++)
	{
		ans = ans*i;
	}
	return ans;
}


// long
// strtol(const char *s, char **endptr, int base)
// {
//   int neg = 0;
//   long val = 0;

//   // gobble initial whitespace
//   while (*s == ' ' || *s == '\t')
//     s++;

//   // plus/minus sign
//   if (*s == '+')
//     s++;
//   else if (*s == '-')
//     s++, neg = 1;

//   // hex or octal base prefix
//   if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
//     s += 2, base = 16;
//   else if (base == 0 && s[0] == '0')
//     s++, base = 8;
//   else if (base == 0)
//     base = 10;

//   // digits
//   while (1) {
//     int dig;

//     if (*s >= '0' && *s <= '9')
//       dig = *s - '0';
//     else if (*s >= 'a' && *s <= 'z')
//       dig = *s - 'a' + 10;
//     else if (*s >= 'A' && *s <= 'Z')
//       dig = *s - 'A' + 10;
//     else
//       break;
//     if (dig >= base)
//       break;
//     s++, val = (val * base) + dig;
//     // we don't properly detect overflow!
//   }

//   if (endptr)
//     *endptr = (char *) s;
//   return (neg ? -val : val);
// }


void umain(int argc,char **argv)
{
	if(argc > 2)
	{
		cprintf("wrong input\n");
		return;
	}
	if(argc == 1)
	{
		cprintf("give the input number\n");
		return;
	}
	char *num = argv[1];
	if (checkInt(num)==0)
	{
		cprintf("Please enter a positive integer input\n");
		return;
	}
	long answer,a1;
	answer = strtol(num,NULL,10);
	if(answer < 0)
	{
		cprintf("enter positive number\n");
		return;
	}
	a1 = fact(answer);
	cprintf("%ld\n",a1);
}