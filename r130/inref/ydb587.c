/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	*
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

int main()
{
	ci_name_descriptor callin;
	int status;

	ydb_init();
	callin.rtn_name.address = "tst";
	callin.rtn_name.length = 3;
	callin.handle = NULL;
	status = ydb_cip(&callin);
	return 0;
}
