/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.      *
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
#include <string.h>
#include <stdlib.h>

/*This program calls ydb_init() and then prints out the
values of $gtm_dist and $ydb_dist to ensure that ydb_init()
is setting both values correctly.*/

int main()
{
	const char *gtm_dist, *ydb_dist;

	ydb_init();
	gtm_dist = getenv("gtm_dist");
	ydb_dist = getenv("ydb_dist");
	if (!strcmp(gtm_dist, ydb_dist))
	{
		printf("passed\n");
	} else
	{
	printf("$gtm_dist = %s\n", gtm_dist);
	printf("$ydb_dist = %s\n", ydb_dist);
	}
	return 0;
}
