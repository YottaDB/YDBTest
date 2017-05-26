/****************************************************************
 *								*
 *	Copyright 2014 Fidelity Information Services, Inc	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include "gtm_stdio.h"
#include "gtmxc_types.h"

int main()
{
	gtm_status_t ret;
	gtm_char_t msg[1000];
	gtm_init();
	fflush(stdout);
	ret = gtm_ci("callin");
	return 0;
}
