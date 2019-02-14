/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	*
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
#define	MAXINT4		0x7fffffff
#define	VARNAMESLIT	"varnames "

int main()
{
	int	i, status, seed, namecount, actualnamecount;
	char	ch, errbuf[ERRBUF_SIZE], *varnamesptr, *endptr;

	seed = (time(NULL) * getpid());
	srand48(seed);

	/* Choose a random positive namecount > YDB_MAX_NAMES */
	namecount = YDB_MAX_NAMES + 1 + ((MAXINT4 - YDB_MAX_NAMES) * drand48());
	for (i = 0; i < 3; i++)
	{
		if (0 == i)
			status = ydb_tp_s(NULL, NULL, NULL, namecount, NULL);
		else if (1 == i)
			status = ydb_lock_s(1000000000, namecount, NULL, 0, NULL);
		else
			status = ydb_delete_excl_s(namecount, NULL);
		YDB_ASSERT(YDB_ERR_NAMECOUNT2HI == status)
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		/* Remove "namecount" value printed (after checking it) to make the output deterministic */
		varnamesptr = strstr(errbuf, VARNAMESLIT);
		YDB_ASSERT(NULL != varnamesptr);
		varnamesptr += strlen(VARNAMESLIT);
		ch = varnamesptr[0];
		varnamesptr[0] = '\0';
		printf("Returned error : %s", errbuf);
		varnamesptr[0] = ch;
		actualnamecount = strtoul(varnamesptr, &endptr, 10);
		if (namecount == actualnamecount)
			printf("NNNN");	/* Replace variable namecount parameter with deterministic NNNN */
		else
			printf("Expected : %d : Actual = %d", namecount, actualnamecount);
		printf("%s\n", endptr);
		fflush(stdout);
	}
	return YDB_OK;
}
