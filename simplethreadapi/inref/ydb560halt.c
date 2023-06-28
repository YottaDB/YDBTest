/****************************************************************
 *								*
 * Copyright (c) 2020-2023 YottaDB LLC and/or its subsidiaries.	*
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
#include <signal.h>

#include "libyottadb.h"

int main()
{
	/* Set SIGTERM signal handler to SIG_IGN so YottaDB will not invoke any non-YottaDB signal/exit handler
	 * (due to YDB@ae2721d8).
	 */
	struct sigaction	act;
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;
	act.sa_handler = SIG_IGN;
	sigaction(SIGTERM, &act, NULL);

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
				ydb_eintr_handler_t(YDB_NOTTP, NULL);
				continue;
			}
			break;
		}
	}
	return 0;
}
