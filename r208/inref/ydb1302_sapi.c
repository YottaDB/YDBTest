/****************************************************************
 *								*
 * Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* After an error interrupts a simpleAPI lock call, the next lock call must not issue BADLOCKNEST, and a later
 * ydb_lock_incr_s() of a name in the interrupted call must acquire that lock.
 */

#include "libyottadb.h"

#include <stdio.h>
#include <string.h>

/* Check that status is the expected one. expname names it in the output. */
static void check_status(char *what, int status, int expected, char *expname)
{
	if (expected == status)
		printf("PASS : %s returned %s\n", what, expname);
	else
		printf("WRONG : %s returned status %d, expected %s\n", what, status, expname);
}

/* Check that another process finds the lock on name held */
static void check_held(char *what, char *name)
{
	char	cmd[256], result[64];
	FILE	*fp;

	snprintf(cmd, sizeof(cmd), "$ydb_dist/yottadb -run held^ydb1302 %s", name);
	fflush(stdout);
	fp = popen(cmd, "r");
	if ((NULL == fp) || (NULL == fgets(result, sizeof(result), fp)))
		strcpy(result, "<no output>\n");
	if (NULL != fp)
		pclose(fp);
	if (0 == strcmp(result, "held\n"))
		printf("PASS : after %s, another process finds %s held\n", what, name);
	else
		printf("WRONG : after %s, another process finds %s %s", what, name, result);
}

/* Inside TP, release a lock acquired before the transaction started, which issues TPLOCK */
static int tp_decr(void *parm)
{
	check_status("ydb_lock_decr_s(clock) inside ydb_tp_s()", ydb_lock_decr_s((ydb_buffer_t *)parm, 0, NULL),
			YDB_ERR_TPLOCK, "YDB_ERR_TPLOCK");
	return YDB_OK;
}

int main(void)
{
	ydb_buffer_t	alock, block, clock, longsub;
	char		subbuf[256];

	YDB_LITERAL_TO_BUFFER("alock", &alock);
	YDB_LITERAL_TO_BUFFER("block", &block);
	YDB_LITERAL_TO_BUFFER("clock", &clock);
	memset(subbuf, 'x', sizeof(subbuf));	/* One byte over the 255 byte limit for lock subscripts */
	longsub.buf_addr = subbuf;
	longsub.len_alloc = longsub.len_used = sizeof(subbuf);

	printf("# LOCKSUB2LONG on the second name of ydb_lock_s()\n");
	check_status("ydb_lock_s(alock, alock(<256 bytes>))", ydb_lock_s(0, 2, &alock, 0, NULL, &alock, 1, &longsub),
			YDB_ERR_LOCKSUB2LONG, "YDB_ERR_LOCKSUB2LONG");
	check_status("ydb_lock_incr_s(block)", ydb_lock_incr_s(0, &block, 0, NULL), YDB_OK, "YDB_OK");
	check_held("ydb_lock_incr_s(block)", "block");
	check_status("ydb_lock_incr_s(alock)", ydb_lock_incr_s(0, &alock, 0, NULL), YDB_OK, "YDB_OK");
	check_held("ydb_lock_incr_s(alock)", "alock");
	check_status("ydb_lock_s() with no names, to release all locks", ydb_lock_s(0, 0), YDB_OK, "YDB_OK");

	printf("# TPLOCK from ydb_lock_decr_s() inside ydb_tp_s()\n");
	check_status("ydb_lock_incr_s(clock)", ydb_lock_incr_s(0, &clock, 0, NULL), YDB_OK, "YDB_OK");
	check_status("ydb_tp_s()", ydb_tp_s(tp_decr, &clock, NULL, 0, NULL), YDB_OK, "YDB_OK");
	check_status("ydb_lock_incr_s(block)", ydb_lock_incr_s(0, &block, 0, NULL), YDB_OK, "YDB_OK");
	check_held("ydb_lock_incr_s(block)", "block");
	check_status("ydb_lock_s() with no names, to release all locks", ydb_lock_s(0, 0), YDB_OK, "YDB_OK");
	return 0;
}
