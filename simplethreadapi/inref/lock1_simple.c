/****************************************************************
 *								*
 * Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <stdlib.h>

#include "libyottadb.h"

#define VARNAME1	"lockA"
#define VARNAME2	"^lockA"
#define SUB21		"42"
#define SUB31		"simpleAPI"
#define SUB32		"lock"
#define SUB33		"uh-huh"
#define SUB34		"oooooh"
#define SUB35		"shiney!"
#define	LOCK_TIMEOUT	(unsigned long long)100000000000	/* 100 * 10^9 nanoseconds == 100 seconds */

#define ERRBUF_SIZE	1024

#define CHECK_FOR_ERROR(STATUS) 								\
{												\
	if (YDB_OK != STATUS)									\
	{											\
		if (YDB_LOCK_TIMEOUT == STATUS)							\
			fprintf(stderr, "Lock timed out [%d] !!???\n", __LINE__);		\
		else										\
		{										\
			ydb_zstatus(errbuf, ERRBUF_SIZE);					\
			fflush(stdout);								\
			fprintf(stderr, "ydb_lock_st() [%d]: %s\n", __LINE__, errbuf);		\
			fflush(stderr);								\
		}										\
		return STATUS;									\
	}											\
}

/* Routine to create a few locks (some local, some global, then use LKE to display them.
 *
 * Locks to create:
 *   - lockA, ^lockB
 *   - lockA(42), ^lockB(42)
 *   - lockA("simpleAPI","lock","uh-huh","oooooh","shiney!"), ^lockB("simpleAPI","lock","uh-huh","oooooh","shiney!")
 *
 * The first two sets are created in one call (with an LKE check), and the 3rd set is created by itself which should
 * cause the first two sets to be released.
 *
 */
int main()
{
	ydb_buffer_t	varname1, varname2, subary2, subary3[5];	/* The variable names are sub<set#><subscr#> */
	int		status;
	char		errbuf[ERRBUF_SIZE];

	YDB_LITERAL_TO_BUFFER(VARNAME1, &varname1);
	YDB_LITERAL_TO_BUFFER(VARNAME2, &varname2);
	/* subary2 (single parm) is just a simple ydb_buffer_t so no need to get complex there. However, subary3
	 * needs to have the subscript set into it.
	 */
	YDB_LITERAL_TO_BUFFER(SUB21, &subary2);
	YDB_LITERAL_TO_BUFFER(SUB31, &subary3[0]);
	YDB_LITERAL_TO_BUFFER(SUB32, &subary3[1]);
	YDB_LITERAL_TO_BUFFER(SUB33, &subary3[2]);
	YDB_LITERAL_TO_BUFFER(SUB34, &subary3[3]);
	YDB_LITERAL_TO_BUFFER(SUB35, &subary3[4]);

	/* Do the first and second lock sets */
	status = ydb_lock_st(YDB_NOTTP, LOCK_TIMEOUT, 4, &varname1, 0, NULL, &varname2, 0, NULL, &varname1, 1, &subary2, &varname2, 1, &subary2);
	CHECK_FOR_ERROR(status);
	/* Show list of locks we have obtained */
	printf("\nlock1_simple: List of locks after setting groups 1 and 2:\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	/* Now to the 3rd set, this should release the previous locks */
	status = ydb_lock_st(YDB_NOTTP, LOCK_TIMEOUT, 2, &varname1, 5, (ydb_buffer_t *)&subary3, &varname2, 5, (ydb_buffer_t *)&subary3);
	CHECK_FOR_ERROR(status);
	/* Show list of locks we have obtained and make sure earlier locks were freed */
	printf("\n\nlocks1: List of locks after setting group 3:\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	/* Now a final check to see if running ydb_lock_s with no parmcnt unlocks all locks */
	status = ydb_lock_st(YDB_NOTTP, LOCK_TIMEOUT, 0);
	CHECK_FOR_ERROR(status);
	/* See what locks are left if any (should all be gone) */
	printf("\n\nlocks1: List of locks after zero argument call to ydb_lock_st() which should release all locks\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	printf("lock1_simple complete\n");
	fflush(stdout);
	return YDB_OK;
}
