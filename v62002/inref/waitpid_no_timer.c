/****************************************************************
*								*
 * Copyright (c) 2013-2015 Fidelity National Information 	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include "gtmxc_types.h"
#include "gtm_sizeof.h"

#include <time.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>

/*
 * This is a helper script for v62002/waitpid_no_timer test. Invoked from M as an external routine,
 * this script sets up a timer, whose handler either does a call-in to cause the CLOSE of an open
 * pipe or sends a SIGTERM signal to itself.
 */

void alarm_handler(gtm_tid_t tid, gtm_int_t hd_len, char *hdata);

#define BUF_LEN 1024

/* Do a series of short sleeps for up to X seconds unless the STOP flag gets set. */
#define SLEEP_FOR_X_SECONDS(X, STOP)							\
{											\
	struct timespec	sleep_time;							\
	int 		i, ret_status;							\
											\
	sleep_time.tv_sec = 0;								\
	sleep_time.tv_nsec = 200000000;							\
	ret_status = 0;									\
	for (i = 0; (i < X * 5) && !(STOP); i++)					\
		ret_status = nanosleep(&sleep_time, NULL);				\
	if ((-1 == ret_status) && (EINTR != errno))					\
	{										\
		printf("TEST-E-FAIL, The nanosleep() call failed: %d\n", errno);	\
		fflush(stdout);								\
	}										\
}

gtm_char_t buf[BUF_LEN];

int waitpid_timer_handler(gtm_int_t count, gtm_int_t test)
{
	int flag, *flag_ptr;

	if (gtm_init())
	{
		printf("gtm_init() failed: \n");
		gtm_zstatus(&buf[0], BUF_LEN);
		printf("%s\n", buf);
		fflush(stdout);
		return 1;
	}
	printf("In waitpid_timer_handler(), will start a timer for 0 seconds.\n");
	flag = test;
	flag_ptr = &flag;
	gtm_start_timer((gtm_tid_t)alarm_handler, 0, alarm_handler, SIZEOF(char *), (char *)&flag_ptr);
	SLEEP_FOR_X_SECONDS(10, !flag);
	if (flag)
	{
		gtm_cancel_timer((gtm_tid_t)alarm_handler);
		printf("TEST-E-FAIL, Timer set for 0 seconds was not processed in 10.");
		fflush(stdout);
		return 2;
	}
	return 0;
}

void alarm_handler(gtm_tid_t tid, gtm_int_t hd_len, char *hdata)
{
	printf("In alarm_handler().\n");
	if (1 == **(int **)hdata)
	{
		printf("Will do a call-in to close the pipe.\n");
		if (gtm_ci("wpthci"))
		{
			printf("gtm_ci() failed: \n");
			gtm_zstatus(&buf[0], BUF_LEN);
			printf("%s\n", buf);
		}
	} else
	{
		printf("Will issue a SIGTERM to ourselves.\n");
		kill(getpid(), SIGTERM);
	}
	**(int **)hdata = 0;
	fflush(stdout);
}
