/****************************************************************
 *								*
 * Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* YDB#737: Call-in APIs don't know how to handle $quit */
#include "libyottadb.h"
#include <stdio.h>
#include <assert.h>

#define maxmsg 2048    /* maximum length of a YottaDB message */

int main() {
	ydb_status_t status;
	ydb_long_t xecute_return;
	char msg[maxmsg];

	fprintf(stdout, "Testing $quit behavior without error trap\n");
	status = ydb_ci("quit1", &xecute_return, "set x=123");
	if (status != YDB_OK) {
		ydb_zstatus(msg, maxmsg);
		fprintf(stderr, "Failure of quit1-1 with error: %s\n", msg);
		status = 0;
	} else {
		printf("quit1 return value : Expected = 5 : Actual = %ld\n", xecute_return);
		xecute_return = 0; //reset
	}

	fprintf(stdout, "Testing $quit behavior with error trap\n");
	status = ydb_ci("quit1", &xecute_return, "write 1/0");
	if (status != YDB_OK) {
		ydb_zstatus(msg, maxmsg);
		fprintf(stderr, "Failure of quit1-2 with error: %s\n", msg);
		status = 0;
	} else {
		printf("quit1 return value : Expected = 150373210 : Actual = %ld\n", xecute_return);
		xecute_return = 0; //reset
	}
}
