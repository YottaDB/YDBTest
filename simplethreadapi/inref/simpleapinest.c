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
#include <stdlib.h>
#include <time.h>

#define ERRBUF_SIZE	1024

#define BASEVAR "^basevar"
#define VALUE1	"value"

char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, badbasevar;

int main()
{
	int			status, n;
	ci_name_descriptor	callin_ci;

	printf("### Test of SIMPLEAPINEST error###\n"); fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	srand(time(NULL));

	callin_ci.rtn_name.address = ("simpleapinestci");
	callin_ci.rtn_name.length = strlen(callin_ci.rtn_name.address);
	callin_ci.handle = NULL;

	printf("# Do SET of global that invokes a trigger###\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	YDB_ASSERT(YDB_OK == status);

	printf("\n# Test that YDB_ERR_SIMPLEAPINEST error is not issued when using ydb_ci_t()/ydb_cip_t()\n"); fflush(stdout);
	printf("# Test randomly starting with ydb_ci_t()/ydb_cip_t()\n"); fflush(stdout);

	n = rand() % 2;

	if (n == 0)
	{
		status = ydb_ci_t(YDB_NOTTP, NULL, "simpleapinestci");
		YDB_ASSERT(YDB_OK == status);
	} else
	{
		status = ydb_cip_t(YDB_NOTTP, NULL, &callin_ci);
		YDB_ASSERT(YDB_OK == status);
	}

	return YDB_OK;
}

