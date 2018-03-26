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

#include "libyottadb.h"

#include <stdio.h>

#include "libydberrors.h"

#define ERRBUF_SIZE	1024
#define	MAXINT4		0x7fffffff

int main()
{
	int		i, status, seed, namecount;
	char		errbuf[ERRBUF_SIZE];
	ydb_string_t	zwrarg;
	ydb_buffer_t	varnames[6];

	zwrarg.address = NULL;			/* Create a null string argument so dumps all locals */
	zwrarg.length = 0;

	printf(" --> Set a few local variables\n"); fflush(stdout);
	status = ydb_ci("setlocals");
	YDB_ASSERT(YDB_OK == status);
	printf("\n --> Dump the local variables\n"); fflush(stdout);
	status = ydb_ci("driveZWRITE", &zwrarg);
	YDB_ASSERT(YDB_OK == status);

	YDB_LITERAL_TO_BUFFER("y", &varnames[0]);
	YDB_LITERAL_TO_BUFFER("x", &varnames[1]);
	YDB_LITERAL_TO_BUFFER("%z", &varnames[2]);
	YDB_LITERAL_TO_BUFFER("^xyz", &varnames[3]);
	YDB_LITERAL_TO_BUFFER("$trestart", &varnames[4]);
	YDB_LITERAL_TO_BUFFER("mm", &varnames[5]);

	printf("\n --> Use ydb_delete_excl_s() to delete all local variables except [y]\n"); fflush(stdout);
	status = ydb_delete_excl_s(1, varnames);
	printf("\n --> Dump the local variables\n"); fflush(stdout);
	status = ydb_ci("driveZWRITE", &zwrarg);
	YDB_ASSERT(YDB_OK == status);

	printf(" --> Set the few local variables again\n"); fflush(stdout);
	status = ydb_ci("setlocals");
	YDB_ASSERT(YDB_OK == status);
	printf("\n --> Use ydb_delete_excl_s() to delete all local variables except [x] and [%%z]\n"); fflush(stdout);
	status = ydb_delete_excl_s(2, &varnames[1]);
	printf("\n --> Dump the local variables\n"); fflush(stdout);
	status = ydb_ci("driveZWRITE", &zwrarg);
	YDB_ASSERT(YDB_OK == status);

	printf(" --> Set the few local variables again\n"); fflush(stdout);
	status = ydb_ci("setlocals");
	YDB_ASSERT(YDB_OK == status);
	printf("\n --> Use ydb_delete_excl_s() to delete all local variables\n"); fflush(stdout);
	status = ydb_delete_excl_s(0, NULL);
	printf("\n --> Dump the local variables\n"); fflush(stdout);
	status = ydb_ci("driveZWRITE", &zwrarg);
	YDB_ASSERT(YDB_OK == status);

	printf("\n --> Check that ydb_delete_excl_s() issues INVVARNAME error if global variable name is input\n"); fflush(stdout);
	status = ydb_delete_excl_s(4, &varnames[2]);
	YDB_ASSERT(YDB_ERR_INVVARNAME == status)
	ydb_zstatus(errbuf, ERRBUF_SIZE);
	printf("Returned error : %s\n", errbuf);
	fflush(stdout);

	printf("\n --> Check that ydb_delete_excl_s() issues INVVARNAME error if intrinsic special variable is input\n"); fflush(stdout);
	status = ydb_delete_excl_s(2, &varnames[4]);
	YDB_ASSERT(YDB_ERR_INVVARNAME == status)
	ydb_zstatus(errbuf, ERRBUF_SIZE);
	printf("Returned error : %s\n", errbuf);
	fflush(stdout);

	return YDB_OK;
}
