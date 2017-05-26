#include <string.h>
#include <stdio.h>

#include "shrenv.h"
#include "gtm_stdio.h" 
#include "gtmxc_types.h"

xc_long_t squarec(int count,xc_long_t val)
{
	xc_long_t cube;
	char err[500];

	fflush(stdout);
	PRINTF("\nC2, C-> M -> C -> M\n");
	PRINTF("val = %ld\n",val);
	PRINTF("Using squarec.c The square of %ld is %ld\n",val,val*val);
	if (gtm_ci("cube",&cube,val))
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s \n",err);
		fflush(stdout);
	}
	PRINTF("Call into cubeit^cube returns the cube of %ld as %ld\n",val,cube);
	fflush(stdout);
	return val*val;
}
