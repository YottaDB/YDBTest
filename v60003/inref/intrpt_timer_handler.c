/****************************************************************
*								*
*	Copyright 2013 Fidelity Information Services, Inc	*
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
 * This is a helper script for v60003/intrpt_timer_handler test. Invoked from M as an external routine,
 * this script sets up a timer, whose handler sends a SIGTERM signal to its process.
 */

void alarm_handler(gtm_tid_t tid, gtm_int_t hd_len, char *hdata);

#define SLEEP_FOR_X_SECONDS(X)						\
{									\
	struct timespec	sleep_time;					\
	int 		ret_status;					\
									\
	sleep_time.tv_sec = X;						\
	sleep_time.tv_nsec = 0;						\
	ret_status = nanosleep(&sleep_time, NULL);			\
	if ((-1 == ret_status) && (EINTR != errno))			\
	{								\
		printf("TEST-E-FAIL, The nanosleep() call failed.\n");	\
		fflush(stdout);						\
	}								\
}

int intrpt_timer_handler()
{
	printf("In intrpt_timer_handler(), will start a timer for 0 seconds.\n");
	gtm_start_timer((gtm_tid_t)alarm_handler, 0, alarm_handler, 0, NULL);
	SLEEP_FOR_X_SECONDS(10);
	gtm_cancel_timer((gtm_tid_t)alarm_handler);
	printf("TEST-E-FAIL, Timer set for 0 seconds did not pop in 10.");
	fflush(stdout);
	return 1;
}

void alarm_handler(gtm_tid_t tid, gtm_int_t hd_len, char *hdata)
{
	printf("In alarm_handler(), will issue a kill -15 to ourselves.\n");
	kill(getpid(), SIGTERM);
	SLEEP_FOR_X_SECONDS(10);
	printf("TEST-E-FAIL, Process did not get killed for 10 seconds.");
	fflush(stdout);
	_exit(2);
}
