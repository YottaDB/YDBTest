/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "libyottadb.h"

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>

#define	LOCK_TIMEOUT	1000000
#define ERRBUF_SIZE	1024

#define BASEVAR "basevar"
#define VALUE1	"value"


int main()
{

	int 		i, status, substrlen;
	size_t		size1, size2;
	ydb_char_t	*astr;
	char		errbuf[ERRBUF_SIZE];
	void		*ptr1, *ptr2, *array[1000];

	size1 = 1024;
	srand(time(NULL));

	printf("### Test Functionality of ydb_malloc() and ydb_free() in the SimpleAPI ###\n\n"); fflush(stdout);

	printf("## Test 1: Test ydb_malloc() and ydb_free() with one pointer ##\n"); fflush(stdout);

	printf("# Test that ydb_malloc() assigns a new memory address to a pointer\n"); fflush(stdout);
	printf("Before ydb_malloc(), *ptr1 points to: %p\n", &ptr1); fflush(stdout);
	ptr2 = ptr1;
	ptr1 = ydb_malloc(size1);
	if (ptr1 != ptr2)
	{
		printf("After ydb_malloc(), *ptr1 points to: %p\n", ptr1);
		fflush(stdout);
	}
	else
	{
		printf("Something went wrong\n");
		fflush(stdout);
	}
	printf("# Test that ydb_free() successfully runs with *ptr1\n");
	ydb_free(ptr1);

	printf("\n## Test 2: Test ydb_malloc() and ydb_free() with an array of 1000 pointers ##\n"); fflush(stdout);

	printf("# Allocate the pointers in the array with random allocation amounts\n"); fflush(stdout);
	for (i = 0; i < 1000; i++)
	{
		size2 = rand() % (65536 - 1024) + 1024;
		array[i] = ydb_malloc(size2);
	}

	printf("# Free the allocations of the pointers in the array\n"); fflush(stdout);
	for (i = 0; i < 1000; i++)
	{
		ydb_free(array[i]);
	}

	printf("\n## Test 3: Test using the routine of a separate call-in subtest that uses ydb_malloc()/ydb_free() ##\n"); fflush(stdout);

	astr = (ydb_char_t*)ydb_malloc(32767);
	memset(astr, 'A', 32766);
	astr[32766] = '\0';
	status = ydb_ci("maxstr", astr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
	}

	astr = (ydb_char_t*)ydb_malloc(65536);
	memset(astr, 'A', 65535);
	astr[65535] = '\0';
	status = ydb_ci("maxstr", astr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
	}

	astr = (ydb_char_t*)ydb_malloc(1048576);
	memset(astr, 'A', 1048576);
	astr[1048576] = '\0';
	status = ydb_ci("maxstr", astr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
	}

	return YDB_OK;
}
