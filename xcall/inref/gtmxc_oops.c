#include "shrenv.h"
#include "gtm_stdio.h"
#include "gtmxc_types.h"

#ifdef __MVS__
#pragma export(xc_hello)
#pragma export(xc_oops)
#endif

void	xc_hello ()
{
	PRINTF ("xc_hello\n");
	fflush (stdout);

	return;
}

void	xc_oops (int count, xc_long_t arg1_long, xc_long_t arg2_long)
{
	PRINTF ("xc_oops: count = %d, sizeof(arg1_long) = %d, arg1_long = %d, sizeof(arg2_long) = %d, arg2_long = %d\n",
		count, (int) sizeof(arg1_long), arg1_long, (int) sizeof(arg2_long), arg2_long);
	fflush (stdout);

	return;
}
