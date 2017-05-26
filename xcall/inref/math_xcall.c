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
cleanup(void)
{
	PRINTF("cleanup routine of shared lib called\n");
	fflush(stdout);
}

void
logb10( int count,
                xc_string_t *in_data,
                long length,
                xc_string_t *out_data)
{
        double  i,j;

        in_data->address[length]='\0';
        i = ATOF(in_data->address);
        j = log10(i);
        (void)SPRINTF(out_data->address,"%.15f",j);
        PRINTF("LOGB10 Value = %.15f\n",j);
	fflush(stdout);
        out_data->length = strlen(out_data->address);
}


void
logb10forrealbignamesupto31( int count,
                xc_string_t *in_data,
                long length,
                xc_string_t *out_data)
{
        double  i,j;

        in_data->address[length]='\0';
        i = ATOF(in_data->address);
        j = log10(i);
        (void)SPRINTF(out_data->address,"%.15f",j);
        PRINTF("LOGB10 Value inside function logb10forrealbignamesupto31= %.15f\n",j);
	fflush(stdout);
        out_data->length = strlen(out_data->address);
}

void
lognat(    int count,
                xc_string_t *in_data,
                long length,
                xc_string_t *out_data)
{
        double  i,j;

        in_data->address[length]='\0';
        i = ATOF(in_data->address);
        j = log(i);
        (void)SPRINTF(out_data->address,"%.15f",j);
        PRINTF("LOGNAT Value = %.15f\n",j);
	fflush(stdout);
        out_data->length = strlen(out_data->address);
}

void
xexp( int count,
                xc_string_t *in_data,
                long length,
                xc_string_t *out_data)
{
        double  i,j;

        in_data->address[length]='\0';
        i = ATOF(in_data->address);
        j = exp(i);
        (void)SPRINTF(out_data->address,"%.14f",j);
        PRINTF("EXP Value = %.14f\n",j);
	fflush(stdout);
        out_data->length = strlen(out_data->address);
}

void
xsqrt( int count,
                xc_string_t *in_data,
                long length,
                xc_string_t *out_data)
{
        double  i,j;

        in_data->address[length]='\0';
        i = ATOF(in_data->address);
        j = sqrt(i);
        (void)SPRINTF(out_data->address,"%.14f",j);
        PRINTF("SQRT Value = %.14f\n",j);
	fflush(stdout);
        out_data->length = strlen(out_data->address);
}

