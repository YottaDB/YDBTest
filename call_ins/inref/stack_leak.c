/****************************************************************
*								*
*	Copyright 2013, 2014 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/

/****************************************************************
 ***************************************************************/
#include "gtmxc_types.h"
#include "gtm_sizeof.h"

#include <stdio.h>
#include <errno.h>

#define BUF_LEN 1024

int main()
{
	int		i;
	gtm_char_t	buf[BUF_LEN];

	for (i = 0; i < 100000; i++)
	{	/* Keep calling gtm_init() in attempts to make the stack leak. */
		if (gtm_init())
		{
			printf("gtm_init() failed: \n");
			gtm_zstatus(&buf[0], BUF_LEN);
			printf("%s\n", buf);
			fflush(stdout);
			return -1;
		}

		if (gtm_ci("stackLeak", i))
		{
			printf("gtm_ci() failed: \n");
			gtm_zstatus(&buf[0], BUF_LEN);
			printf("%s\n", buf);
			fflush(stdout);
			return -1;
		}
	}

	/* Rundown the interface. */
	if (gtm_exit())
	{
		gtm_zstatus(&buf[0], BUF_LEN);
		printf("%s\n", buf);
		fflush(stdout);
		return -1;
	}
	return 0;
}
