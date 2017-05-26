/****************************************************************
*								*
*	Copyright 2013, 2014 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/

/****************************************************************
 * Test gtm_start_timer() and gtm_cancel_timer() functionality  *
 * from within a call-in, also ensuring that scheduling a timer *
 * timer with non-positive expiration range does not result in  *
 * an error.                                                    *
 ***************************************************************/
#include "gtmxc_types.h"
#include "gtm_sizeof.h"

#include <time.h>
#include <stdio.h>
#include <errno.h>

#define BUF_LEN 1024

#define SLEEP_AT_MOST_X_SECONDS(X, TEST_CASE)									\
{														\
	struct timespec	sleep_time;										\
	int 		i, ret_status;										\
														\
	sleep_time.tv_sec = 1;											\
	sleep_time.tv_nsec = 0;											\
	for (i = 0; i < X; i++)											\
	{													\
		ret_status = nanosleep(&sleep_time, NULL);							\
		if ((-1 == ret_status) && (EINTR != errno))							\
		{												\
			printf("TEST-E-FAIL, Case %d: The nanosleep() call failed!\n", TEST_CASE);		\
			fflush(stdout);										\
		}												\
		if (flags[TEST_CASE])										\
		{												\
			i = -1;											\
			break;											\
		}												\
	}													\
	if (i >= 0)												\
	{													\
		gtm_cancel_timer((gtm_tid_t)alarm_handler);							\
		printf("TEST-E-FAIL, Case %d: The timer did not pop in %d seconds\n", TEST_CASE, X);		\
		fflush(stdout);											\
	}													\
}

#define START_TIMER_FOR_X_SECONDS(X, TEST_CASE)									\
{														\
	int *flag_ptr;												\
														\
	flag_ptr = flags + TEST_CASE;										\
	gtm_start_timer((gtm_tid_t)alarm_handler, X * 1000, alarm_handler, SIZEOF(int *), (char *)&flag_ptr);	\
}

void alarm_handler(gtm_tid_t tid, gtm_int_t hd_len, char *hdata);

static int flags[4];

int main()
{
	int		test_case = 0;
	gtm_char_t	buf[BUF_LEN];

	/* Initialize the interface. */
	if (gtm_init())
	{
		gtm_zstatus(&buf[0], BUF_LEN);
		printf("%s\n", buf);
		fflush(stdout);
		return -1;
	}

	/* Schedule a timer for 3 seconds, and immediately cancel it; If the timer does not get scheduled, gtm_cancel_timer() timer
	 * is a no-op; if the timer fails to be canceled, then the following test case will fail an assert. If the timer pops before
	 * we get to cancel it, then the box is being slow, and we report no issue.
	 */
	START_TIMER_FOR_X_SECONDS(3, test_case);
	gtm_cancel_timer((gtm_tid_t)alarm_handler);
	test_case++;

	/* Schedule a timer for 3 seconds and verify that we get a pop in at most 15. */
	START_TIMER_FOR_X_SECONDS(3, test_case);
	SLEEP_AT_MOST_X_SECONDS(15, test_case);
	test_case++;

	/* Schedule a timer for 0 seconds, and make sure we get a pop in at most 15. */
	START_TIMER_FOR_X_SECONDS(0, test_case);
	SLEEP_AT_MOST_X_SECONDS(15, test_case);
	test_case++;

	/* Schedule a timer for -10 seconds, and make sure we get a pop in at most 15. */
	START_TIMER_FOR_X_SECONDS(-10, test_case);
	SLEEP_AT_MOST_X_SECONDS(15, test_case);

	/* Rundown the interface. */
	if (gtm_exit())
	{
		gtm_zstatus(&buf[0], BUF_LEN);
		printf("%s\n", buf);
		fflush(stdout);
		return -1;
	}
	return 0;
}

void alarm_handler(gtm_tid_t tid, gtm_int_t hd_len, char *hdata)
{
	**(int **)hdata = 1;
}
