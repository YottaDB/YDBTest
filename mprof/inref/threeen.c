/*
 * This sample C program is used as a time-intensive task for testing MPROF 
 * with external calls. It is invoked from D9L06002815.
 */
#include "stdlib.h"
#include "gtmxc_types.h"

long max = 1, max_index = 1;
long size = 0;

long getSeqLength(long num)
{
	long temp;

	if (num == 1)
		return 1;
	if (num % 2)
		temp = 3 * num + 1;
	else
		temp = num / 2;
	temp = getSeqLength(temp) + 1;
	if (temp > max)
	{
		max = temp;
		max_index = num;
	}
	return temp;
}

void solve3nPlus1(int count, gtm_long_t arg_size)
{
	long i;
	int r, reps = 300;
	
	size = arg_size;
	for (r = 0; r < reps; r++)
		for (i = 1; i <= size; i++)
			getSeqLength(i);
	return;
}
