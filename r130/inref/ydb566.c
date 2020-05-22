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
#include <string.h>
#include <stdlib.h>

#include "libyottadb.h"

/* This test ensures that the call-in table supports comments and blank lines. It will
 * print out a success message if the comments in the Call-In file are correctly handled
 * or an error message otherwise. It will also test a commented out call-in mapping
 * to ensure that it returns the correct error status (ERR_CINOENTRY).
 */

int main()
{
	int			status, ci_return_code;
	ci_name_descriptor	callin1, callin2, callin3;

	ydb_init();
	callin1.rtn_name.address = "tst";
	callin1.rtn_name.length = 3;
	callin1.handle = NULL;
	callin2.rtn_name.address = "tst2";
	callin2.rtn_name.length = 4;
	callin2.handle = NULL;
	callin3.rtn_name.address = "//tst2";
	callin3.rtn_name.length = 6;
	callin3.handle = NULL;
	status = ydb_cip(&callin1, &ci_return_code);
	if (YDB_OK != status)
		printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
	if (0 != ci_return_code)
		printf("FAIL: call-in to tst returned the incorrect value. Got: %d; Expected: %d\n", ci_return_code, 0);
	printf("Testing a commented out call-in mapping to ensure that it is not called and returns ERR_CINOENTRY. ");
	printf("If everything is working correctly, there will be no additional output.\n");
	status = ydb_cip(&callin2, &ci_return_code);
	if ((YDB_ERR_CINOENTRY * -1) != status)
		printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", status, (YDB_ERR_CINOENTRY * -1));
	status = ydb_cip(&callin3, &ci_return_code);
	if ((YDB_ERR_CINOENTRY * -1) != status)
		printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", status, (YDB_ERR_CINOENTRY * -1));
}
