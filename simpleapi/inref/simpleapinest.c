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

#define BASEVAR "^basevar"
#define VALUE1	"value"

char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, badbasevar;

int main()
{
	int		status;

	printf("### Test of SIMPLEAPINEST error###\n"); fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	printf("# Do SET of global that invokes a trigger###\n"); fflush(stdout);
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	YDB_ASSERT(YDB_OK == status);
	return YDB_OK;
}

