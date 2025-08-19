/****************************************************************
 *								*
 * Copyright (c) 2020-2025 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Test the newly added return code from ydb_zstatus() and that it returns INVSTRLEN when
 * the buffer is not big enough. Also, if the buffer is uninitialized, return INVSTRLEN
 * instead of trying to copy to a NULL buffer.
 */

#include <string.h>
#include <stdio.h>

#include "libyottadb.h"

int main()
{
	ydb_buffer_t	varname, errstr, value;
	unsigned char	errbuf[2048];
	int		status, errors;

	errors = 0;
	YDB_LITERAL_TO_BUFFER("$xyz", &varname);				/* A (currently) non-existant ISV */
	memset(&errstr, 0, sizeof(errstr));					/* Unallocated errstr */
	YDB_MALLOC_BUFFER(&value, 100);
	status = ydb_get_st(YDB_NOTTP, &errstr, &varname, 0, NULL, &value);	/* Fetch non-existent ISV */
	if (YDB_OK == status)
	{
		printf("ydb515: ERROR - found value that doesn't exist !?!?\n");
		exit(1);
	}
	/* Fetch failed as expected - attempt to fetch the buffer with a too-small buffer */
	status = ydb_zstatus(errbuf, 16);
	if (YDB_ERR_INVSTRLEN != status)
	{
		printf("ydb515: Error - expected INVSTRLEN error from ydb_zstatus - got %d instead (A)\n", status);
		errors++;
	}
	printf("ydb515: Partial error buffer received: %s\n", errbuf);
	/* Try again with a zero sized buffer - first set buffer to 0xff */
	errbuf[0] = 0xff;							/* Set marker - see if gets overridden */
	status = ydb_zstatus(errbuf, 0);
	if (YDB_ERR_INVSTRLEN != status)
	{
		printf("ydb515: Error - expected INVSTRLEN error from ydb_zstatus - got %d instead (B)\n", status);
		errors++;
	}
	if (0xff != errbuf[0])
	{
		printf("ydb515: Error - marker overridden in output buffer - now contains 0x%02x\n", (unsigned int)errbuf[0]);
		errors++;
	}
	/* Try one last time with full sized buffer to make sure it still works */
	status = ydb_zstatus(errbuf, (int)sizeof(errbuf));
	if (YDB_OK != status)
	{
		printf("ydb515: Error - unexpected error code %d\n", status);
		errors++;
	} else
		printf("ydb515: Fetched error: %s\n", errbuf);
	if (0 == errors)
		printf("ydb515: PASS\n");
	else
		printf("ydb515: FAIL\n");
}
