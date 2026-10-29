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

/* A SimpleAPI program whose ydb_malloc() call asks for 64MiB. A block that large is passed straight to malloc(), so
 * white box case WBTEST_HOLD_FORK_LOCK_IN_MALLOC (413) stops inside it. ydb_malloc() initializes YottaDB first, which
 * sets up the signal handlers. The process is expected to be killed before the call returns.
 */

#include <stdio.h>

#include "libyottadb.h"

#define	MALLOC_SIZE	(64 * 1024 * 1024)

int main(void)
{
	void	*ptr;

	ptr = ydb_malloc(MALLOC_SIZE);
	printf("FAIL : the process was not killed\n");
	fflush(stdout);
	ydb_free(ptr);
	return 0;
}
