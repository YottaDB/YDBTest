/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries. *
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
#include <unistd.h>

#define ERRBUF_SIZE	1024
#define ISVPAIRS	7

typedef struct
{
	char	*isvname;		/* Name of ISV/SVN */
	char	*newvalue;		/* Value we will set into it */
	int	isvname_len;
	int	newvalue_len;
} ISV_name_value_pair;

static ISV_name_value_pair ISVs_and_values[ISVPAIRS] = {
	{"$ECODE", ",Z151027730,", sizeof("$ECODE") - 1, sizeof(",Z151027730,") - 1},
	{"$ETRAP", "set $ecode=\"\"", sizeof("$ETRAP") - 1, sizeof("set $ecode=\"\"") - 1},
	{"$ZMAXTPTIME", "55", sizeof("$ZMAXTPTIME") - 1, sizeof("55") - 1},
	{"$ZPROMPT", "YottaDB>", sizeof("$ZPROMPT") - 1, sizeof("YottaDB>") - 1},
	{"$ZINTERRUPT", "zwrite \"*\"", sizeof("$ZEDITOR") - 1, sizeof("zwrite \"*\"") - 1},
	/* Add some settings we expect to cause errors */
	{"$NOTEXIST", "N/A", sizeof("$NOTEXIST") - 1, sizeof("N/A") - 1},	/* Non-existant ISV */
	{"$HOROLOG", "0", sizeof("$HOROLOG") - 1, 1}				/* Can't be set */
};

/* Simple routine to take a set of ISVs and SET new values in them to something else - no randomization */
int main()
{
	ISV_name_value_pair	*ISVPair, *ISVPair_top;
	ydb_buffer_t		isvvar, isvvalue;
	ydb_string_t		zshowarg;
	int			status;
	char			errbuf[ERRBUF_SIZE];

	/* First, drive ZSHOW to show values unaltered */
	printf("ZSHOW prior to setting new values for some ISVs\n");
	fflush(stdout);							/* Keep in sync with non-stream IO of YDB */
	zshowarg.address = "\"I\"";
	zshowarg.length = sizeof("\"I\"") - 1;
	status = ydb_ci("driveZSHOW", &zshowarg);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZSHOW error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	usleep(325000);							/* Terminal flush after 300K us */
	fflush(stdout); fflush(stderr);
	/* Reset each of the chosen ISVs (except the intentional errors) */
	for (ISVPair = ISVs_and_values, ISVPair_top = ISVPair + ISVPAIRS; ISVPair < ISVPair_top; ISVPair++)
	{
		isvvar.buf_addr = ISVPair->isvname;
		isvvar.len_alloc = isvvar.len_used = ISVPair->isvname_len;
		isvvalue.buf_addr = ISVPair->newvalue;
		isvvalue.len_alloc = isvvalue.len_used = ISVPair->newvalue_len;

		/* Note - no call to ydb_init() to verify it happens automatically */

		status = ydb_set_s(&isvvar, 0, NULL, &isvvalue);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ydb_set_s() of %s and value %s: %s\n", ISVPair->isvname, ISVPair->newvalue, errbuf);
			/* Not exiting after errors now .. try them all .. and we expect *some* errors */
		} else
			printf("ydb_set_s() set %s to value %s\n", ISVPair->isvname, ISVPair->newvalue);
		fflush(stdout);
	}
	usleep(325000);							/* Terminal flush after 300K us */
	fflush(stdout); fflush(stderr);
	printf("\n\n\nZSHOW *after* setting new values for some ISVs\n");
	fflush(stdout);							/* Keep in sync with non-stream IO of YDB */
	status = ydb_ci("driveZSHOW", &zshowarg);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZSHOW error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
}
