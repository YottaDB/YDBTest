/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <time.h>
#include <errno.h>

#include "libyottadb.h"

int main()
{
	struct timespec slptime, remtime;
	int		ret;

	ydb_init();	/* Needed so signal handlers are established for SIGINT/SIGTERM instead of default action which is
			 * to restart the interrupted nanosleep() call OR terminate the process respectively.
			 */
	slptime.tv_sec = (1 << 20);	/* A large timeout so this process will be eternally sleeping until interrupted */
	slptime.tv_nsec = 0;
	for ( ; ; )
	{
		ret = nanosleep(&slptime, &remtime);
		if (-1 == ret)
		{
			if (EINTR == errno)
			{
				ydb_eintr_handler();
				continue;
			}
			break;
		}
	}
	return 0;
}
