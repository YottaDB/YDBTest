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

#include "libyottadb.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main()
{
	int		status, stat, ret;
	ydb_buffer_t	parentvar, childvar, value;
	char		valuebuff[64];
	pid_t		child, pid;

	pid = getpid();
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER("^parent", &parentvar);
	YDB_LITERAL_TO_BUFFER("^child", &childvar);
	value.buf_addr = &valuebuff[0];
	value.len_alloc = sizeof(valuebuff);
	printf("Parent pid : Set ^parent=<parentpid> with ydb_set_s()\n"); fflush(stdout);
	value.len_used = sprintf(value.buf_addr, "%d", (int)pid);
	status = ydb_set_s(&parentvar, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	printf("Parent pid : Sleep 2 seconds so flush timer will do AIO writes to DB\n"); fflush(stdout);
	sleep(2);
	printf("Parent pid : Fork child after parent has done AIO writes\n"); fflush(stdout);
	child = fork();
	if (0 == child)
	{	/* child */
		pid = getpid();
		status = ydb_child_init(NULL);	/* needed in child pid right after a fork() */
		YDB_ASSERT(YDB_OK == status);
		value.len_used = sprintf(value.buf_addr, "%d", (int)pid);
		printf("Child pid : Set ^child=<childpid> with ydb_set_s()\n"); fflush(stdout);
		status = ydb_set_s(&childvar, 0, NULL, NULL);
		YDB_ASSERT(YDB_OK == status);
		printf("Child pid : Sleep 2 seconds so flush timer in child will do AIO writes to DB\n"); fflush(stdout);
		sleep(2);
		printf("Child pid : Halting\n"); fflush(stdout);
	} else
	{	/* parent */
		/* Wait for child to terminate */
		printf("Parent pid : Waiting for child to terminate\n"); fflush(stdout);
		ret = waitpid(child, &stat, 0);
		YDB_ASSERT(-1 != ret);
		printf("Parent pid : Halting\n"); fflush(stdout);
	}
	return YDB_OK;
}
