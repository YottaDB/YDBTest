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

/* Routine to invoke ydb_fork_n_core() without first setting up the YDB environment */

int main()
{
	ydb_fork_n_core();		/* Drive the routine - should produce an error and return */
	printf("ydb_fork_n_core() has been driven\n");
	return -1;
}
