/****************************************************************
 *								*
 * Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Usage: ydb1294_ci
 *
 * Calls in to ci^rl1294 (call-in table entry rl1294ci), which does a BREAK and so enters direct mode inside the
 * call-in, then prints the status ydb_ci() returned.
 */

#include "libyottadb.h"

#include <stdio.h>

int main(void)
{
	char	errbuf[1024];
	int	status;

	status = ydb_ci("rl1294ci");
	printf("ydb_ci returned %d\n", status);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("%s\n", errbuf);
	}
	return status;
}
