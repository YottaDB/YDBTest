/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.      *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "gtmxc_types.h"

/* This prints a success message if the external call succeeds.
 * It also contains a function that should not be successfully
 * called because its definition is commented out in the external
 * call definition file.
 */
void print_success(void)
{
	printf("External Call Succeeded\n");
}

void print_failure(void)
{
	printf("This should not have been printed. Comments are broken in external calls.\n");
}
