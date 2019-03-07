/****************************************************************
 *                                                              *
 * Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.      *
 * All rights reserved.                                         *
 *                                                              *
 *      This source code contains the intellectual property     *
 *      of its copyright holder(s), and is made available       *
 *      under a license.  If you do not know the terms of       *
 *      the license, please stop and do not read further.       *
 *                                                              *
 ****************************************************************/
#include "libyottadb.h"
#include <stdio.h>
#include <string.h>

int main()
{
	int	status;

	printf("ydb184.c : Do a call-in invocation of ydb184.m with ydb_ci()\n");
	status = ydb_ci("ydb184");
}
