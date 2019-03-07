/****************************************************************
 *								*
 * Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "libyottadb.h"

#include <stdio.h>

#define ERRBUF_SIZE	1024

#define YDB_MAX_TIME_NSEC        (0x7fffffffllu * 1000llu * 1000llu)     /* Max specified time in (long long) nanoseconds */

int main()
{
	int			i, j, status;
	ydb_buffer_t		basevar, value;
	char			errbuf[ERRBUF_SIZE], *fnname[5] = {
					"ydb_lock_s",
					"ydb_lock_incr_s",
					"ydb_timer_start",
					"ydb_hiber_start",
					"ydb_hiber_start_wait_any"
				};
	unsigned long long	time[2];

	time[0] = YDB_MAX_TIME_NSEC;
	time[1] = YDB_MAX_TIME_NSEC + 1;

	/* Initialize varname */
	YDB_LITERAL_TO_BUFFER("basevar", &basevar);

	for (i = 0; i < 2; i++)
	{
		for (j = 0; j < 5; j++)
		{
			if (0 == j)
				status = ydb_lock_s(time[i], 1, &basevar, 0, NULL);
			else if (1 == j)
				status = ydb_lock_incr_s(time[i], &basevar, 0, NULL);
			else
			{	/* For the remaining functions, a good huge timeout will cause the test to run
				 * for a long time so disable the good value.
				 */
				if (0 == i)
					continue;
				if (2 == j)
					status = ydb_timer_start(0, time[i], NULL, 0, NULL);
				else if (3 == j)
					status = ydb_hiber_start(time[i]);
				else
					status = ydb_hiber_start_wait_any(time[i]);
			}
			if (YDB_OK != status)
			{
				ydb_zstatus(errbuf, ERRBUF_SIZE);
				printf("%s() : time = 0x%llx : Returned error : %s\n", fnname[j], time[i], errbuf);
				fflush(stdout);
			} else
			{
				printf("%s() : time = 0x%llx : Returned success\n", fnname[j], time[i]);
				fflush(stdout);
			}
		}
	}
	return YDB_OK;
}
