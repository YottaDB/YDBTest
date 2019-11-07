/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.      *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "stdio.h"

#include "libyottadb.h"

/* Do a simple set of a global to a null value that is setup to drive a trigger but the trigger
 * drives an M routine that does not exist. This test validates that the SFF_NORET_VIA_MUMTSTART_OFF
 * stack frame flag is turned off properly after an error. If this was not the case, this test
 * case would get an assert failure in error_return() when run in debug mode.
 */
int main()
{
	int		status1, status2;
	ydb_buffer_t	basevar;
	char		errbuf[1024];

	YDB_LITERAL_TO_BUFFER("^gbl", &basevar);
	status1 = ydb_set_s(&basevar, 0, NULL, NULL);
	if (YDB_OK != status1)
	{
		ydb_zstatus(errbuf, sizeof(errbuf));
		if (YDB_ERR_ZLINKFILE == status1)
			fprintf(stderr, "Expected failure of ydb_set_s(): %s\n", errbuf);
		else
			fprintf(stderr, "Unexpected failure of ydb_set_s(): %s\n", errbuf);
	} else
		fprintf(stderr, "Expected failure from ydb_set_s() DID NOT OCCUR !!! ?? !!!\n");
	return status1;
}

