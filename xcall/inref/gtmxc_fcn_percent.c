/*	gtmxc_fcn_percent.c - percent as the first M label function character get mapped to underscore in external calls.
 *
 *	This module provides one GT.M external call callable function which
 *	start with an underscore character.  The function prints its name
 *	for easy verification.
 */

#include <limits.h>
#include "gtm_stdio.h"
#include "gtmxc_types.h"
#include "shrenv.h"

/*	gtm_fcnpercent - no return value.
 *
 */

void	_gtm_fcnpercent()
{
	PRINTF("_gtm_fcnpercent\n");
	fflush(stdout);

	return;
}
