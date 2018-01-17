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

/* To build:
 *   gt_cc_dbg lock1.c
 *   $gt_ld_linker $gt_ld_option_output lock1 $gt_ld_options_common lock1.o $gt_ld_sysrtns -Wl,-rpath,$gtm_dist -L$gtm_dist -lgtmshr $gt_ld_syslibs > lock1.map
 *
 * To run:
 *   lock1
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
			fprintf(stderr, "ydb_lock_s() [%d]: %s\n", __LINE__, errbuf);		\
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

	YDB_STRLIT_TO_BUFFER(&varname1, VARNAME1);
	YDB_STRLIT_TO_BUFFER(&varname2, VARNAME2);
	/* subary2 (single parm) is just a simple ydb_buffer_t so no need to get complex there. However, subary3
	 * needs to have the subscript set into it.
	 */
	YDB_STRLIT_TO_BUFFER(&subary2, SUB21);
	YDB_STRLIT_TO_BUFFER(&subary3[0], SUB31);
	YDB_STRLIT_TO_BUFFER(&subary3[1], SUB32);
	YDB_STRLIT_TO_BUFFER(&subary3[2], SUB33);
	YDB_STRLIT_TO_BUFFER(&subary3[3], SUB34);
	YDB_STRLIT_TO_BUFFER(&subary3[4], SUB35);

	/* Do the first and second lock sets */
	status = ydb_lock_s(999, 4, &varname1, 0, NULL, &varname2, 0, NULL, &varname1, 1, &subary2, &varname2, 1, &subary2);
	CHECK_FOR_ERROR(status);
	/* Show list of locks we have obtained */
	printf("\nlock1: List of locks after setting groups 1 and 2:\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	/* Now to the 3rd set, this should release the previous locks */
	status = ydb_lock_s(999, 2, &varname1, 5, (ydb_buffer_t *)&subary3, &varname2, 5, (ydb_buffer_t *)&subary3);
	CHECK_FOR_ERROR(status);
	/* Show list of locks we have obtained and make sure earlier locks were freed */
	printf("\n\nlocks1: List of locks after setting group 3:\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	/* Now a final check to see if running ydb_lock_s with no parmcnt unlocks all locks */
	status = ydb_lock_s(999, 0);
	CHECK_FOR_ERROR(status);
	/* See what locks are left if any (should all be gone) */
	printf("\n\nlocks1: List of locks after zero argument call to ydb_lock_s() which should release all locks\n");
	fflush(stdout);
	system("$gtm_dist/lke show -all -wait");
	printf("lock1 complete\n");
	fflush(stdout);
	return YDB_OK;
}
