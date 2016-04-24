#include <inc/lib.h>

void parser(char* input,char* a[])
{
	int no_inputs = countstrings(input);
	char *out[no_inputs];
	int i=0;
	int j=0;
	char a = input[j];
	while(a!='\n')
	{	
		count = 0;
		int temp = j;
		while(a!=' ')
		{
			count ++;
			j++;
			a = input[j];
		}
		out[i] = malloc(count+1);
		int k;
		for(k=0;k<count;k++)
		{
			out[i][k] = input[k + temp];
		}
		out[i][count] = '\0';
		i++;
	}
	return out;
}

int countstrings(char* input)
{
	int i=0;
	char a = input[i];
	int count = 0;
	while(a!='\n')
	{
		if(a == ' ')
		{
			count +=1;
		}
		i +=1;
		a = input[i];
	}
	return count;
}