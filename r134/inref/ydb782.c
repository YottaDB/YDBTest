/****************************************************************
 *								*
 * Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	*
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
#include <sys/wait.h>	/* for "waitpid" prototype */
#include <unistd.h>	/* for "fork" prototype */
#include <errno.h>

#define	BASEVAR			"^basevar"
#define LOCK_TIMEOUT_1MSEC	(unsigned long long)1000000        /* 10^6 nanoseconds == 1 millisecond */

int main()
{
	ydb_buffer_t		basevar;
	int			i, status, save_errno;
	pid_t			child_pid, ret;
	unsigned long long	timeout;

	for (i = 0; i < 2; i++) {
		timeout = LOCK_TIMEOUT_1MSEC * i;
		printf("## --------------------------------------------------------\n");
		printf("## Test ydb_lock_incr_s() with timeout = [%lld nanoseconds]\n", timeout);
		printf("## --------------------------------------------------------\n");
		YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
		printf("## Parent : Lock %s using ydb_lock_incr_s() with timeout = [%lld nanoseconds]\n", BASEVAR, timeout);
		status = ydb_lock_incr_s(0, &basevar, 0, NULL);
		printf("## Parent : Verify return status from ydb_lock_incr_s() is YDB_OK\n");
		YDB_ASSERT(YDB_OK == status);
		printf("## Parent : Create a child process using fork() call\n");
		fflush(stdout);	/* Needed so child does not inherit unflushed buffers and prints them again */
		child_pid = fork();
		YDB_ASSERT(0 <= child_pid);
		if (0 == child_pid)
		{
			printf("## Child : Lock %s using ydb_lock_incr_s() with timeout = [%lld nanoseconds]\n", BASEVAR, timeout);
			status = ydb_lock_incr_s(0, &basevar, 0, NULL);
			printf("## Child : Verify return status from ydb_lock_incr_s() is YDB_LOCK_TIMEOUT\n");
			YDB_ASSERT(YDB_LOCK_TIMEOUT == status);
			return 0;
		}
		/* Wait for child to terminate */
		do
		{
			ret = waitpid(child_pid, &status, 0);
			save_errno = errno;
		} while ((-1 == ret) && (EINTR == save_errno));
		YDB_ASSERT(-1 != ret);
	}
	return 0;
}
