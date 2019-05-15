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
#include <string.h>
#include "libyottadb.h"

#define TEST_STRING1 "Far out in the uncharted backwaters of the"
#define TEST_STRING2 "unfashionable end of the western spiral arm"
ydb_string_t toPass;
int type;


/* initializes a 1MiB buffer in memory
 */
int stackSet(){
	char stackBuffer[0x100000]; //A 1MiB buffer
	memset(stackBuffer, 0x1, 0x100000); //initialize it to some arbitrary value
	return 0;
}

/* calls ydb_ci() at various nest levels up to 126
 */
int nestHelper(int n){
	int status;
	status = ydb_ci("ciStringProc", &toPass, type);
	YDB_ASSERT(status == YDB_OK);
	if (n == 126){
		return status;
	} else {
		return nestHelper(n+1);
	}
}

/* this passes TEST_STRING1 to the M function (at varying levels of nesting) and checks for equality
 * it then allocates a large buffer on to the stack in order to initialize it
 * then it repeats the same test using TEST_STRING2 on the same char* pointer
 */
int main(){
	int status;
	char str[50];

	strcpy(str, TEST_STRING1);
	toPass.address = str;
	toPass.length = strlen(str);
	type = 1;
	status = ydb_ci("ciStringProc", &toPass, type);
	YDB_ASSERT(status == YDB_OK);
	status = nestHelper(0);
	YDB_ASSERT(status == YDB_OK);

	status = stackSet();

	strcpy(str, TEST_STRING2);
	toPass.address = str;
	toPass.length = strlen(str);
	type = 2;
	status = ydb_ci("ciStringProc", &toPass, type);
	YDB_ASSERT(status == YDB_OK);
	status = nestHelper(0);
	YDB_ASSERT(status == YDB_OK);
	return 0;
}
