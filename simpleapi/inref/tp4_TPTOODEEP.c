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

#define	ERRBUF_SIZE	1024

char		errbuf[ERRBUF_SIZE];
int		gvnset();
int		level;
ydb_tpfnptr_t	tpfn;

int main()
{
	int		status;

	printf(" ### Test TPTOODEEP error ###\n");
	fflush(stdout);

	tpfn = &gvnset;
	status = ydb_tp_s(tpfn, NULL, NULL, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_tp_s() exit status = %d : %s\n", status, errbuf);
		fflush(stdout);
	}
	return status;
}

/* Function to set a global variable */
int gvnset()
{
	int		status;

	printf("Entering ydb_tp_s() : Level = %d\n", level++);
	return ydb_tp_s(tpfn, NULL, NULL, 0, NULL);
}
