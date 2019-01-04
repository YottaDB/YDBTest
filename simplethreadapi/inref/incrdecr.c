/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* To build:
 *   gt_cc_dbg incrdecr.c
 *   $gt_ld_linker $gt_ld_option_output incrdecr $gt_ld_options_common incrdecr.o $gt_ld_sysrtns -Wl,-rpath,$gtm_dist -L$gtm_dist -lgtmshr $gt_ld_syslibs > incrdecr.map
 *
 * To run:
 *   incrdecr
 */

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

#define CHECK_FOR_ERROR(STATUS)										\
{													\
	if (YDB_OK != STATUS)										\
	{												\
		if (YDB_LOCK_TIMEOUT == STATUS)								\
			fprintf(stderr, "Lock timed out [%d] !!???\n", __LINE__);			\
		else											\
		{											\
			ydb_zstatus(errbuf, ERRBUF_SIZE);						\
			fflush(stdout);									\
			fprintf(stderr, "ydb_lock_{incr/decr}_st() [%d]: %s\n", __LINE__, errbuf);	\
			fflush(stderr);									\
		}											\
		return STATUS;										\
	}												\
}

/* Routine to create a few locks (some local, some global, then use LKE to display them.
 *
 * Locks to create:
 *   - lockA, ^lockB
 *   - lockA(42), ^lockB(42)
 *   - lockA("simpleAPI","lock","uh-huh","oooooh","shiney!"), ^lockB("simpleAPI","lock","uh-huh","oooooh","shiney!")
 *
 * Create the first two locks from the first set using one call. The rest of the locks are created using ydb_lock_incr_st()
 * with periodic ydb_lock_decr_st() calls on vars and using LKE to display the current state of the locks.
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
	status = ydb_lock_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, 2, &varname1, 0, NULL, &varname2, 0, NULL);
	CHECK_FOR_ERROR(status);
	/* Show list of locks we have obtained */
	printf("\nincrdecr: List of locks after setting the 1st set of vars:\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	/* Add in the second set as incremental locks */
	status = ydb_lock_incr_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, &varname1, 1, &subary2);
	CHECK_FOR_ERROR(status);
	status = ydb_lock_incr_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, &varname2, 1, &subary2);
	CHECK_FOR_ERROR(status);
	/* Show list of locks we have obtained to verify first and 2nd set are locked */
	printf("\n\nincrdecr: List of locks after adding the 2nd set of vars:\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	/* Now release the first set of locks */
	status = ydb_lock_decr_st(YDB_NOTTP, NULL, &varname1, 0, NULL);
	CHECK_FOR_ERROR(status);
	status = ydb_lock_decr_st(YDB_NOTTP, NULL, &varname2, 0, NULL);
	CHECK_FOR_ERROR(status);
	/* Show list of locks we have obtained to verify both first and 2nd sets are locked */
	printf("\n\nincrdecr: List of locks after removing the 1st set:\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	/* Add in the 3rd set of vars */
	status = ydb_lock_incr_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, &varname1, 5, (ydb_buffer_t *)&subary3);
	CHECK_FOR_ERROR(status);
	status = ydb_lock_incr_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, &varname2, 5, (ydb_buffer_t *)&subary3);
	CHECK_FOR_ERROR(status);
	/* Remove the second var from the second set */
	status = ydb_lock_decr_st(YDB_NOTTP, NULL, &varname2, 1, &subary2);
	CHECK_FOR_ERROR(status);
	/* Show list of locks to verify 3rd set and first var of second set are locked */
	printf("\n\nincrdecr: List of locks after adding 3rd set and removing 1st var of second set:\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	/* Now a final check to see if running ydb_lock_s with no parmcnt unlocks all locks */
	status = ydb_lock_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, 0);
	CHECK_FOR_ERROR(status);
	/* See what locks are left if any (should all be gone) */
	printf("\n\nincrdecr: List of locks after zero argument call to ydb_lock_st() which should release all locks:\n\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	printf("\nincrdecr complete\n\n\n");
	fflush(stdout);
	return YDB_OK;
}
