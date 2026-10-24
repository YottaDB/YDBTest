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

/* Get a SIGSEGV because the stack cannot grow, in a process that uses YottaDB and has not installed an
 * alternate signal stack.
 *
 * 1. Restore the default action of SIGSEGV and disable any alternate signal stack. An ASAN build links this program
 *    with ASAN, which installs a SIGSEGV handler and an alternate signal stack before main() runs. After YottaDB
 *    reports a SIGSEGV, it passes the signal to a handler that was there before it, and the ASAN handler ends the
 *    process with the default action of SIGSEGV. This step makes the process start with neither, with or without ASAN.
 * 2. Initialize YottaDB with one ydb_set_s() call, which installs the YottaDB signal handlers.
 * 3. Limit the stack to 8MiB (or the hard limit if that is lower), so that the next step reaches the limit
 *    quickly whatever limit the process started with.
 * 4. Recurse with a 4KiB frame per call until the stack cannot grow any more.
 *
 * The YottaDB SIGSEGV handler can run only on an alternate signal stack, as the main stack is full.
 */
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <sys/resource.h>
#include "libyottadb.h"

#define STACK_LIMIT	(8 * 1024 * 1024)
#define FRAME_SIZE	4096

/* Each call passes its frame to the next one and reads it after that call returns, so that the compiler
 * cannot turn the recursion into a loop.
 */
static int descend(volatile char *caller_frame, int depth)
{
	volatile char	frame[FRAME_SIZE];

	memset((char *)frame, depth, sizeof(frame));
	return descend(frame, depth + 1) + caller_frame[depth % FRAME_SIZE];
}

int main(void)
{
	ydb_buffer_t	var, val;
	struct rlimit	rl;
	stack_t		ss;
	volatile char	frame[FRAME_SIZE];
	int		status;
	char		zbuf[1024];

	printf("pid %d\n", getpid());
	fflush(stdout);
	/* Disable any alternate signal stack already in place, such as the one that ASAN installs before main() runs in
	 * an ASAN build, so that the process has none when YottaDB initializes, which is the case this program tests.
	 */
	memset(&ss, 0, sizeof(ss));
	ss.ss_flags = SS_DISABLE;
	if (0 != sigaltstack(&ss, NULL))
	{
		perror("FAIL : sigaltstack(SS_DISABLE)");
		return 1;
	}
	/* Restore the default action of SIGSEGV, replacing any handler already in place, such as the one that ASAN
	 * installs. After reporting a fatal signal, YottaDB passes it to the handler that was in place when it
	 * initialized. The ASAN handler would then end the process with the default action of SIGSEGV, so the exit
	 * status would be 139 even though YottaDB reported the signal.
	 */
	if (SIG_ERR == signal(SIGSEGV, SIG_DFL))
	{
		perror("FAIL : signal(SIGSEGV, SIG_DFL)");
		return 1;
	}
	YDB_LITERAL_TO_BUFFER("x", &var);
	YDB_LITERAL_TO_BUFFER("init", &val);
	status = ydb_set_s(&var, 0, NULL, &val);
	if (YDB_OK != status)
	{
		ydb_zstatus(zbuf, sizeof(zbuf));
		printf("FAIL : ydb_set_s() returned %d : %s\n", status, zbuf);
		return 1;
	}
	if (0 != getrlimit(RLIMIT_STACK, &rl))
	{
		perror("FAIL : getrlimit(RLIMIT_STACK)");
		return 1;
	}
	if ((RLIM_INFINITY == rl.rlim_max) || (STACK_LIMIT < rl.rlim_max))
		rl.rlim_cur = STACK_LIMIT;
	else
		rl.rlim_cur = rl.rlim_max;
	if (0 != setrlimit(RLIMIT_STACK, &rl))
	{
		perror("FAIL : setrlimit(RLIMIT_STACK)");
		return 1;
	}
	printf("recursing until the stack cannot grow\n");
	fflush(stdout);
	memset((char *)frame, 0, sizeof(frame));
	status = descend(frame, 0);
	printf("FAIL : the recursion returned %d\n", status);
	return 1;
}
