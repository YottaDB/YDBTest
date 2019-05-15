/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Test of ydb_ci() when taking a string as a parameter, and returning void, properly processes the string parameter
 */

#include <stdio.h>
#include "libyottadb.h"

#define TEST_STRING1 "Far out in the uncharted backwaters of the"
#define TEST_STRING2 "unfashionable end of the western spiral arm"

/* this does a series of callins to an M program
 * it calls the M program with TEST_STRING1 and tests to see that it passed correctly
 * it then repeats the same test with TEST_STRING2 using the same char* pointer
 */
int main() {
	char str[50];
	ydb_string_t toPass;
	int status, i;

	strcpy(str, TEST_STRING1);
	toPass.address = str;
	toPass.length = strlen(str);
	for(i = 0; i < 10000; i++){
		status = ydb_ci("ciStringProc", &toPass, 1);
		YDB_ASSERT(status == YDB_OK);
	}

	strcpy(str, TEST_STRING2);
	toPass.address = str;
	toPass.length = strlen(str);
	for(i = 0; i < 10000; i++){
		status = ydb_ci("ciStringProc", &toPass, 2);
		YDB_ASSERT(status == YDB_OK);
	}
	return 0;
}

