/****************************************************************
 *								*
 * Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* The below C program is a copy of "ydb_init.c" from https://gitlab.com/YottaDB/DB/YDB/-/issues/854#description */

#include "libyottadb.h"

#include <stdio.h>

int	main()
{
	int	status;
	char	errbuf[1024];

	status = ydb_init();
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_init() returned status = %d\n", status);
		printf("ydb_zstatus() returned : %s\n", errbuf);
		fflush(stdout);
	}
}
