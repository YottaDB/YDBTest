/****************************************************************
 *								*
 * Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "libyottadb.h"

#define ERRBUF_SIZE	1024

enum {
	useHALT = 1,
	useZHALT,
	useZGOTO0,
	useQUITretval
};

/*
 * See test_ci_z_halt_rc.csh for test description. Series of call-ins that terminate in various ways. We are testing to make sure
 * they termination in an acceptable fashion (i.e. lack of explosions and correct errors generated). Note the return value is
 * pre-set before each call so we can see under which conditions the return value is being left unset.
 */
int main(void)
{
	ydb_status_t		status;
	ydb_int_t		retintval;
	ydb_string_t		retstrval;
	char			errbuf[ERRBUF_SIZE];
	char			retbuf[32];

	status = ydb_init();		/* Initialize call-in environment */
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
		return 0;
	}

	/* First is a series of integer return value tests */

	printf("main: Initializing return value to -99 for HALT test\n");
	retintval = -99;
	status = ydb_ci("testcizhaltrcint", &retintval, useHALT);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: After HALT, return value is %d\n\n", retintval);

	printf("main: Initializing return value to -99 for ZHALT test\n");
	retintval = -99;
	status = ydb_ci("testcizhaltrcint", &retintval, useZHALT);
	if (status)
	{
		printf("Return code: %d\n", status);
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: After ZHALT, return value is %d\n\n", retintval);

	printf("main: Initializing return value to -99 for ZGOTO 0 test\n");
	retintval = -99;
	status = ydb_ci("testcizhaltrcint", &retintval, useZGOTO0);
	if (status)
	{
		printf("Return code: %d\n", status);
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: After ZGOTO 0, return value is %d\n\n", retintval);

	printf("main: Initializing return value to -99 for QUIT with no return value (but one expected) test\n");
	retintval = -99;
	status = ydb_ci("testcizhaltrcint", &retintval, useQUITretval);
	if (status)
	{
		printf("Return code: %d\n", status);
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: After QUIT with no return value (but one expected), return value is %d\n\n", retintval);

	printf("main: Setting up for QUIT with (an unexpected integer) return value test\n");
	status = ydb_ci("testcizhaltnoretv",1);
	if (status)
	{
		printf("Return code: %d\n", status);
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: Return from QUIT with (an unexpected integer) return value\n\n");

	/* Now the same treatment for a string return */

	printf("main: Initializing return value to 'snarf' for the HALT test\n");
	retstrval.address = retbuf;
	strcpy(retbuf, "snarf");
	retstrval.length = sizeof("snarf") - 1;
	status = ydb_ci("testcizhaltrcstr", &retstrval, useHALT);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: After HALT, return value is %.*s\n\n", (int)retstrval.length, retstrval.address);

	printf("main: Initializing return value to 'snarf' for the ZHALT test\n");
	retstrval.address = retbuf;
	strcpy(retbuf, "snarf");
	retstrval.length = sizeof("snarf") - 1;
	status = ydb_ci("testcizhaltrcstr", &retstrval, useZHALT);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: After ZHALT, return value is %.*s\n\n", (int)retstrval.length, retstrval.address);

	printf("main: Initializing return value to 'snarf' for the ZGOTO 0 test\n");
	retstrval.address = retbuf;
	strcpy(retbuf, "snarf");
	retstrval.length = sizeof("snarf") - 1;
	status = ydb_ci("testcizhaltrcstr", &retstrval, useZGOTO0);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: After ZGOTO 0, return value is %.*s\n\n", (int)retstrval.length, retstrval.address);

	printf("main: Initializing return value to 'snarf' for the QUIT with no return value (but one expected) test\n");
	retstrval.address = retbuf;
	strcpy(retbuf, "snarf");
	retstrval.length = sizeof("snarf") - 1;
	status = ydb_ci("testcizhaltrcstr", &retstrval, useQUITretval);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: After QUIT with (an unexpected) return value, return value is %.*s\n\n",
	       (int)retstrval.length, retstrval.address);

	printf("main: Setting up for QUIT with (an unexpected string) return value test\n");
	status = ydb_ci("testcizhaltnoretv",0);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: Return from QUIT with (an unexpected string) return value\n\n");

	/* Make a call to routines we have already called (using a different entry id) but with 2 args instead
	 * of 1 which is 1 more than expected. Should get an error - once for int and once for string retvals.
	 */

	printf("main: Setting up for call to routine with an extra (unexpected) argument\n");
	retintval = -99;
	status = ydb_ci("testcizhalt2manyargsint", &retintval, useHALT);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: Return from calling routine with an unexpected arg (integer retval flavor)\n\n");

	printf("main: Setting up for call to routine with an extra (unexpected) argument\n");
	retstrval.address = retbuf;
	strcpy(retbuf, "snarf");
	retstrval.length = sizeof("snarf") - 1;
	status = ydb_ci("testcizhalt2manyargsint", &retstrval, useHALT);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: Return from calling routine with an unexpected arg (string retval flavor)\n\n");


	/* Now make a call with arguments to a routine that isn't expecting any - expect error */

	printf("main: Initializing return value to -99 for the call with args to routine with no parms test\n");
	retintval = -99;
	status = ydb_ci("testcizhaltnoargs", &retintval, 42);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}
	printf("main: Returned from testcizhaltnoargs\n\n");

	/* Test complete - Close up shop */
	status = ydb_exit();
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Return code: %d\n", status);
		printf("%s\n", errbuf);
		fflush(stdout);
	}

	return 0;
}
