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

#include <libyottadb.h>

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>
#include <signal.h>

#define ERRBUF_SIZE	1024
#define ONESEC		((unsigned long long)1000000000)

int main()
{
	int			status, stime, etime, ftime;
	unsigned long long	time2, badtime;
	char			errbuf[ERRBUF_SIZE];
	pid_t			parent, child;

	printf("### Test Functionality of ydb_hiber_start()/ydb_hiber_start_wait_any() in the SimpleAPI ###\n"); fflush(stdout);

	printf("\n# Test ydb_hiber_start() with sleep_nsec set to 2 seconds\n");

	time2 = 2;
	stime = time(NULL);
	status = ydb_hiber_start(time2*ONESEC);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	etime = time(NULL);
	ftime = etime - stime;

	/* Can be slower on slower boxes */
	if (ftime >= (int)time2 && ftime <= (int)time2 + 1)
	{
		printf("ydb_hiber_start() successfully slept for 2 seconds\n");
		fflush(stdout);
	}

	printf("\n# Test ydb_hiber_start_wait_any() with sleep_nsec set to 2 seconds\n");
	stime = time(NULL);
	status = ydb_hiber_start_wait_any(time2*ONESEC);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	etime = time(NULL);
	ftime = etime - stime;

	if (ftime >= (int)time2 && ftime <= (int)time2 + 1)
	{
		printf("ydb_hiber_start_wait_any() successfully slept for 2 seconds\n");
		fflush(stdout);
	}

	printf("\n# Test that ydb_hiber_start_wait_any() will stop sleeping after recieving a signal\n");
	printf("# Set sleep_nsec to 20 seconds\n");
	printf("# Fork a child process which will wait 2 seconds and then send a signal to the parent process\n");
	printf("# This signal should wake the ydb_hiber_start_wait_any() call at 2 seconds instead of 20 seconds\n"); fflush(stdout);

	parent = getpid();
	child = fork();
	if (0 == child)
	{
		/* Sleep 2 seconds and then send SIGALRM to parent process */
		sleep(time2);
		kill(parent, SIGALRM);
		return YDB_OK;
	} else
	{
		stime = time(NULL);
		status = ydb_hiber_start_wait_any(2*ONESEC);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("Line[%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}

	}
	etime = time(NULL);
	ftime = etime - stime;
	if (ftime >= (int)time2 && ftime <= (int)time2 + 1)
	{
		printf("ydb_hiber_start_wait_any() was successfully interrupted after 2 seconds\n");
		fflush(stdout);
	}

	return YDB_OK;
}
