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

#include <stdio.h>
#include <unistd.h>

#include "libyottadb.h"
#include "gtmxc_types.h"

/* Used by ydb1180 test to invoke ydb_ci and gtm_ci and ensure
 * $ECODE will be cleared before each invocation.
 * ydb1180ma will cause a zero division error, setting $ECODE.
 * ydb1180WE will print the value of $ECODE.
 * If $ECODE is empty, we know it was properly cleared.
 */
int main()
{
	ydb_ci("ydb1180ma");
	ydb_ci("ydb1180WE");
	gtm_ci("ydb1180ma");
	gtm_ci("ydb1180WE");
}
