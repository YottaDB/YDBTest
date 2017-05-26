#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#if defined(__alpha)
	typedef __int64 gtm64_int;
#else
	typedef int64_t gtm64_int;
#endif

int getprime (int n);

int main (int argc, char *argv[])
{
	int cnt, not_unique;
	long i, root, range, from, num, prime;
	char *arr;

	if (argc == 1)
	{
		printf("\nUsage:\n %s prime_number",argv[0]);
		exit (1);
	}
		
	range = atoi(argv[1]);
	prime = getprime(range);
	arr = (char *) malloc(sizeof(char) * prime);

	cnt = 0;
	printf("\nprmroot;");
	printf("\n    set ^prime=%ld",prime);
	for (root=2+(prime/10); root<prime; root++) 
	{
		not_unique = 0;
		memset(arr, 0, sizeof(char) * prime);
		num = 1;
		arr[1] = num;
		for (i = 1; i <= prime - 2; i++)
		{
			num = ((gtm64_int)num * root) %  (gtm64_int)prime;
			if (arr[num])
			{
				not_unique = 1; 
				break;
			}
			arr[num] = 1;
		}
		if (!not_unique)
		{
			cnt++;
			printf("\n    set ^root(%d)=%ld ", cnt, root);
		}
		if (cnt == 10) 
			break;
	}
	printf("\n    quit\n");
}

/* Returns first prime # >= n */
int getprime (int n)
{
	int m, p;

	for (m = n | 1 ; ; m += 2)
	{
		for (p = 3 ; ; p += 2)
		{
			if (p * p > m)
				return m;
			if (0 == m % p)
				break;
		}
	}
}
