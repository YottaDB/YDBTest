/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.*
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

#include "libydberrors.h"

#define ERRBUF_SIZE	1024

char	errbuf[ERRBUF_SIZE];

int	gvnset();

int main()
{
	int		i, status;
	char		errbuf[ERRBUF_SIZE];
	ydb_tp2fnptr_t	tpfn;

	tpfn = &gvnset;

	printf("Start a TP transaction through ydb_tp_st()\n"); fflush(stdout);
	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, NULL, 0, NULL);
	YDB_ASSERT(YDB_ERR_CALLINTCOMMIT == status);
	ydb_zstatus(errbuf, ERRBUF_SIZE);
	printf("Returned error from ydb_tp_st() : %s\n", errbuf); fflush(stdout);
	return YDB_OK;
}

/* Function to set a global variable */
int gvnset(uint64_t tptoken, ydb_buffer_t *errstr)
{
	int		status;

	printf("Do a call-in inside the function driven by ydb_tp_st()\n"); fflush(stdout);
	status = ydb_ci_t(tptoken, errstr, "callintcommit");
	YDB_ASSERT(-YDB_ERR_CALLINTCOMMIT == status);
	ydb_zstatus(errbuf, ERRBUF_SIZE);
	printf("Returned error from gvnset() : %s\n", errbuf); fflush(stdout);
	return YDB_ERR_CALLINTCOMMIT;
}
