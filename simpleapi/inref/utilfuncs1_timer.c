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

#define ERRBUF_SIZE	1024

#define ONESEC		((unsigned long long)1000000000)

int is_done = 1;

void timer_done(intptr_t timer_id, unsigned int handler_data_len, char *handler_data);

int main()
{
	int 			status, stime, etime, ftime, timer_id;
	unsigned long long	time3;
	char			errbuf[ERRBUF_SIZE], mes[64];

	printf("### Test Functionality of ydb_timer_start()/ydb_timer_cancel() in the SimpleAPI ###\n"); fflush(stdout);

	printf("\n# Test ydb_timer_set() sets a timer which will consequently call a handle function.\n");
	printf("# Execute ydb_timer_set() with limit_nsec set to 3 seconds\n"); fflush(stdout);

	timer_id = time3 = 3*ONESEC;
	stime = time(NULL);
	status = ydb_timer_start(timer_id+1, time3, &timer_done, sizeof(&stime), &stime);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	while(is_done)
	{
		sleep(0.000001);
	}
	is_done = 1;

	printf("\n# Test ydb_timer_cancel() cancels a set timer, which prevents the handle function from being called\n");
	printf("# Set ydb_timer_cancel() to cancel after 1 second\n"); fflush(stdout);
	stime = time(NULL);
	status = ydb_timer_start(timer_id, time3, &timer_done, sizeof(&stime), &stime);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	sleep(1);

	ydb_timer_cancel(timer_id);

	/* Sleep 4 seconds to make sure time is actually cancelled */
	sleep(4);

	printf("ydb_timer_start() successfully cancelled\n"); fflush(stdout);

	return YDB_OK;
}


/* Function timer_done(char mes) executes after time is finished. Prints success message with delivered data to verify function was called */
void timer_done(intptr_t timer_id, unsigned int handler_data_len, char *handler_data)
{
	int 	etime, ftime;

	printf("ydb_timer_start() successfully called timer_done()\n");

	etime = time(NULL);
	ftime = etime - * (int *)handler_data;
	if (ftime >= 3 && ftime < 4)
		printf("Correct amount of time passed after ydb_timer_start()\n");
	fflush(stdout);
	is_done = 0;
}
