/****************************************************************
 *								*
 * Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>

#include "libyottadb.h"

#define ERRBUF_SIZE	1024

/* Routine to invoke ydb_fork_n_core() after first setting up the YDB environment */
int main()
{
	int	status;
	char	errbuf[ERRBUF_SIZE];

	status = ydb_init();
	if (0 != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		fprintf(stderr, "Error occurred during ydb_init() : %s\n", errbuf);
		fflush(stdout);
	}
	ydb_fork_n_core();		/* Drive the routine - should produce a core and return */
	printf("ydb_fork_n_core() has been driven\n");
	return 0;
}
