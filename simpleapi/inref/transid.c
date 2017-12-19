/****************************************************************
 *								*
 * Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	*
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

#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */

#define ERRBUF_SIZE	1024

#define BASEVAR "^baselv"
#define VALUE1	"TP with transid"

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, badbasevar;

int	gvnset();

/* Function to test TID specified in ydb_tp_s() is honored (by finally going into TCOM record in journal file) */
int main()
{
	int		status;
	ydb_buffer_t	tid;
	ydb_tpfnptr_t	tpfn;
	ydb_string_t	zwrarg;

	/* Initialize varname, and value buffers (needed by later "gvnset" invocation inside "ydb_tp_s" */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);

	tpfn = &gvnset;
	/* TID = "BA" */
	status = ydb_tp_s(tpfn, NULL, "BA", NULL);
	assert(YDB_OK == status);
	/* TID = "CS" */
	status = ydb_tp_s(tpfn, NULL, "CS", NULL);
	assert(YDB_OK == status);
	/* TID = "arbitrary str" */
	status = ydb_tp_s(tpfn, NULL, "any str", NULL);
	assert(YDB_OK == status);
	/* TID = "verylongstr" : Test that TID gets truncated to 8 bytes if input is longer than 8 bytes */
	status = ydb_tp_s(tpfn, NULL, "verylongstr", NULL);
	assert(YDB_OK == status);
	return YDB_OK;
}

/* Function to set a global variable */
int gvnset()
{
	int		status;

	/* Set a base variable, no subscripts */
	status = ydb_set_s(&value1, 0, &basevar);
	assert(YDB_OK == status);
	return YDB_OK;
}
