/*
*  these are copies of some of the routines used in profile's xcall
*  the functions are used to test the floating point precision
*/
#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtm_stdlib.h"
#include "gtm_string.h"
#include "gtmxc_types.h"
#include <math.h>

void
logb10( int count,
                xc_char_t *in_data,
                long length,
                xc_char_t *out_data)
{
        double  i,j;

        i = ATOF(in_data);
        j = log10(i);
        (void)SPRINTF(out_data,"%14.6f\n",j);
        PRINTF("LOGB10 Value = %14.6f\n",j);
	fflush(stdout);
}


void
logb10forrealbignamesupto31( int count,
                xc_char_t *in_data,
                long length,
                xc_char_t *out_data)
{
        double  i,j;

        i = ATOF(in_data);
        j = log10(i);
        (void)SPRINTF(out_data,"%14.6f\n",j);
        PRINTF("LOGB10 Value inside function logb10forrealbignamesupto31= %14.6f\n",j);
	fflush(stdout);
}

void
lognat(    int count,
                xc_char_t *in_data,
                long length,
                xc_char_t *out_data)
{
        double  i,j;

        i = ATOF(in_data);
        j = log(i);
        (void)SPRINTF(out_data,"%14.6f\n",j);
        PRINTF("LOGNAT Value = %14.6f\n",j);
	fflush(stdout);
}

void
xexp( int count,
                xc_char_t *in_data,
                long length,
                xc_char_t *out_data)
{
        double  i,j;

        i = ATOF(in_data);
        j = exp(i);
        (void)SPRINTF(out_data,"%14.6f\n",j);
        PRINTF("EXP Value = %14.6f\n",j);
	fflush(stdout);
}

void
xsqrt( int count,
                xc_char_t *in_data,
                long length,
                xc_char_t *out_data)
{
        double  i,j;

        i = ATOF(in_data);
        j = sqrt(i);
        (void)SPRINTF(out_data,"%14.6f\n",j);
        PRINTF("SQRT Value = %14.6f\n",j);
	fflush(stdout);
}

