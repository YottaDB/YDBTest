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

#include <sys/types.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "libyottadb.h"

/* Routine to:
 *   1. Validate signal number input arg (required).
 *   2. Install a handler for that signal.
 *   3. Initialize YDB runtime.
 *   4. Send ourselves that signal.
 *   5. Verify we get into our handler.
 *
 * Note this routine is used both when we except the signal to work (is on the forward list) and when we
 * DO NOT expect the signal to work (is on the exclude list).
 *
 * To build: gt_cc_{pro|dbg} ydb410.c
 * To link:  cc -o ydb410 ydb410.o $gt_ld_sysrtns -Wl,-rpath,$gtm_dist -L$gtm_dist -lyottadb
 */

#define SLEEPTIME 3

void our_ctrlc_handler(int sig, siginfo_t *info, void *context);
void our_ctrlc_handler(int sig, siginfo_t *info, void *context)
{
	printf("ydb410: Signal %d successfully received in our handler\n", sig);
	exit(0);
}

int main(int argc, char **argv, char **envp)
{
	struct sigaction	new_action;
	int			sig, rc;
	char			*endptr;
	ydb_buffer_t		varname, incr;

	/* Parse and validate signal number argument (required) */
	if (2 != argc)
	{
		fprintf(stderr, "ydb410: Extraneous or insufficient argument(s) - need single signal number argument\n");
		exit(1);
	}
	endptr = NULL;
	sig = strtol(argv[1], &endptr, 10);
	if ((NULL == endptr) || ('\0' != *endptr))
	{	/* Some character in the string was not numeric */
		fprintf(stderr, "ydb410: Invalid signal number given: %s\n", argv[1]);
		exit(1);
	}
	if ((1 > sig) || (NSIG < sig))
	{	/* Signal number ouf of range */
		fprintf(stderr, "ydb410: Signal number %d is out of range of 1-%d\n", sig, NSIG);
		exit(1);
	}
	/* Install handler for designed signal before we initialize YDB */
	memset(&new_action, 0, sizeof(new_action));
	sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = SA_SIGINFO | SA_ONSTACK;
	new_action.sa_sigaction = our_ctrlc_handler;
	rc = sigaction(sig, &new_action, NULL);
	if (0 != rc)
	{
		fprintf(stderr, "ydb410: Failure to set sigaction for signal %d: ", sig);
		perror("");
		exit(1);
	}
	/* Drive ydb_incr_st() to cause YDB to initialize in threaded mode and reset the signal handlers */
	YDB_LITERAL_TO_BUFFER("somevar", &varname);
	YDB_LITERAL_TO_BUFFER("1", &incr);
	rc = ydb_incr_st(YDB_NOTTP, NULL, &varname, 0, NULL, &incr, NULL);
	if (YDB_OK != rc)
	{
		fprintf(stderr, "ydb410: Failure from ydb_incr_st() - bad return code: %d\n", rc);
		exit(1);
	}
	/* Everything is in place - now send ourselves a ^C */
	kill(getpid(), sig);
	sleep(SLEEPTIME);
	/* Note that if the signal is not forwarded, if it is a fatal signal, we will never get here */
	fprintf(stderr, "ydb410: Timeout - Did not get signal %d interrupt in %d seconds\n", sig, SLEEPTIME);
	exit(1);
}
