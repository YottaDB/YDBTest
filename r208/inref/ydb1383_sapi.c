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

/* A TP restart that interrupts ydb_lock_s() must not make the next ydb_lock_incr_s() or ydb_lock_decr_s() in the
 * restarted transaction return YDB_ERR_BADLOCKNEST. The argument is "incr" or "decr", and selects the lock call made
 * after the restart.
 */

#include "libyottadb.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static ydb_buffer_t	gbla, gblx;
static int		do_incr;
static char		tries[64];

/* Report a status. A YDB_TP_RESTART is not an error code, so it is not passed to ydb_message(). */
static void check_status(char *what, int status, int expected, char *expname)
{
	char		errbuf[1024];
	ydb_buffer_t	msg;

	if (expected == status)
	{
		printf("PASS : %s returned %s\n", what, expname);
		return;
	}
	if (YDB_TP_RESTART == status)
	{
		printf("FAIL : %s returned YDB_TP_RESTART, expected %s\n", what, expname);
		return;
	}
	msg.buf_addr = errbuf;
	msg.len_alloc = sizeof(errbuf);
	msg.len_used = 0;
	ydb_message(status, &msg);
	printf("FAIL : %s returned %.*s, expected %s\n", what, msg.len_used, msg.buf_addr, expname);
}

/* Check whether another process finds the lock on ^a held */
static void check_held(int expect_held)
{
	char	result[256];
	FILE	*fp;

	fflush(stdout);
	fp = popen("$gtm_dist/mumps -run held^ydb1383 ^a", "r");
	if ((NULL == fp) || (NULL == fgets(result, sizeof(result), fp)))
		strcpy(result, "<no output>\n");
	if (NULL != fp)
		pclose(fp);
	if (expect_held)
		fputs(result, stdout);
	else if (0 == strncmp(result, "FAIL : another process got", strlen("FAIL : another process got")))
		printf("PASS : another process finds ^a free\n");
	else
		printf("FAIL : %s", result);
}

/* The transaction. It restarts with YDB_TP_RESTART until the final retry, where ydb_lock_s() of ^x and ^a opens
 * region AREG for ^a. Opening a region while holding crit in the final retry restarts the transaction.
 */
static int tpfn(void *parm)
{
	ydb_buffer_t	trestart, value;
	char		valbuf[64], numbuf[16];
	int		nrestart, status;
	unsigned int	data;

	YDB_LITERAL_TO_BUFFER("$trestart", &trestart);
	value.buf_addr = valbuf;
	value.len_alloc = sizeof(valbuf) - 1;
	value.len_used = 0;
	status = ydb_get_s(&trestart, 0, NULL, &value);
	if (YDB_OK != status)
		return status;
	valbuf[value.len_used] = '\0';
	nrestart = (int)strtol(valbuf, NULL, 10);
	snprintf(numbuf, sizeof(numbuf), "%s%d", ('\0' == tries[0]) ? "" : ",", nrestart);
	strncat(tries, numbuf, sizeof(tries) - strlen(tries) - 1);
	if (5 <= nrestart)
		return YDB_TP_ROLLBACK;	/* Stop the test from looping if the transaction keeps restarting */
	status = ydb_data_s(&gblx, 0, NULL, &data);	/* region DEFAULT joins the transaction */
	if (YDB_OK != status)
		return status;
	if (3 > nrestart)
		return YDB_TP_RESTART;	/* get to the final retry */
	if (3 == nrestart)
	{	/* Region AREG is not open yet, so this restarts the transaction */
		status = ydb_lock_s(0, 2, &gblx, 0, NULL, &gbla, 0, NULL);
		if (YDB_TP_RESTART != status)
			check_status("ydb_lock_s(^x, ^a) in the final retry", status, YDB_TP_RESTART, "YDB_TP_RESTART");
		return status;
	}
	if (do_incr)
		check_status("ydb_lock_incr_s(^a) after the restart", ydb_lock_incr_s(0, &gbla, 0, NULL), YDB_OK, "YDB_OK");
	else
		check_status("ydb_lock_decr_s(^a) after the restart", ydb_lock_decr_s(&gbla, 0, NULL), YDB_OK, "YDB_OK");
	return YDB_OK;
}

int main(int argc, char *argv[])
{
	if ((2 != argc) || ((0 != strcmp(argv[1], "incr")) && (0 != strcmp(argv[1], "decr"))))
	{
		printf("FAIL : usage is %s incr|decr\n", argv[0]);
		return 1;
	}
	do_incr = (0 == strcmp(argv[1], "incr"));
	YDB_LITERAL_TO_BUFFER("^a", &gbla);
	YDB_LITERAL_TO_BUFFER("^x", &gblx);
	check_status("ydb_tp_s()", ydb_tp_s(tpfn, NULL, NULL, 0, NULL), YDB_OK, "YDB_OK");
	if (0 == strcmp(tries, "0,1,2,3,4"))
		printf("PASS : the transaction restarted from inside ydb_lock_s(^x, ^a) in the final retry\n");
	else
		printf("FAIL : the $TRESTART values of the tries were %s, expected 0,1,2,3,4\n", tries);
	check_held(do_incr);
	return 0;
}
