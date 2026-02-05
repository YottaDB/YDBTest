/****************************************************************
 *								*
 * Copyright (c) 2019-2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Used to create a shared object library for ydb974.
 * This shared object library will be attached to a $ZROUTINES call via wildcard.
 * This should not cause any errors later in the code.
 * The main function should never be run.
 */
#include <stdio.h>

int	main()
{
	printf("This code should never be invoked.\n");
}
