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
#include <sys/types.h>	/* needed for "getpid" */
#include <unistd.h>	/* needed for "getpid" and "fork" */
#include <stdlib.h>	/* needed for "drand48" */
#include <time.h>	/* needed for "time" */

#include "libydberrors.h"

#define ERRBUF_SIZE	1024

int main()
{
	int	i, status, seed, namecount;
	char	errbuf[ERRBUF_SIZE];

	seed = (time(NULL) * getpid());
	srand48(seed);

	namecount = -(0x7fffffff * drand48());	/* choose a random negative namecount */
	for (i = 0; i < 3; i++)
	{
		if (0 == i)
			status = ydb_tp_s(NULL, NULL, NULL, namecount, NULL);
		else if (1 == i)
			status = ydb_lock_s(1000000000, namecount, NULL, 0, NULL);
		else
			status = ydb_delete_excl_s(namecount, NULL);
		YDB_ASSERT(YDB_ERR_INVNAMECOUNT == status)
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Returned error : %s\n", errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
