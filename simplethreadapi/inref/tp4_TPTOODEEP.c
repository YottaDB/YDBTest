/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries. *
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
ydb_tp2fnptr_t	tpfn;

int main()
{
	int		status;

	printf(" ### Test TPTOODEEP error ###\n");
	fflush(stdout);

	tpfn = &gvnset;
	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, NULL, 0, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_tp_st() exit status = %d : %s\n", status, errbuf);
		fflush(stdout);
	}
	return status;
}

/* Function to set a global variable */
int gvnset(uint64_t tptoken, ydb_buffer_t *errstr)
{
	int		status;

	printf("Entering ydb_tp_st() : Level = %d\n", level++);
	return ydb_tp_st(tptoken, errstr, tpfn, NULL, NULL, 0, NULL);
}
