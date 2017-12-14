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

/* Function to do a simple set of 3 Global variable nodes (done in "gvnset()") inside of a TP transaction */
int main()
{
	int		status;
	ydb_buffer_t	tid;
	ydb_tpfnptr_t	tpfn;
	ydb_string_t	zwrarg;

	/* Initialize varname, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);

	tpfn = &gvnset;
	/* TID = "BA" */
	YDB_STRLIT_TO_BUFFER(&tid, "BA");
	status = ydb_tp_s(&tid, NULL, tpfn, NULL);
	assert(YDB_OK == status);
	/* TID = "CS" */
	YDB_STRLIT_TO_BUFFER(&tid, "CS");
	status = ydb_tp_s(&tid, NULL, tpfn, NULL);
	assert(YDB_OK == status);
	/* TID = "arbitrary str" */
	YDB_STRLIT_TO_BUFFER(&tid, "any str");
	status = ydb_tp_s(&tid, NULL, tpfn, NULL);
	assert(YDB_OK == status);
	/* TID = "verylongstr" : Test that TID gets truncated to 8 bytes if input is longer than 8 bytes */
	YDB_STRLIT_TO_BUFFER(&tid, "verylongstr");
	status = ydb_tp_s(&tid, NULL, tpfn, NULL);
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
