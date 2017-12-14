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
#define VALUE1	"TP with comma-separated list of variable names to be preserved"

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, badbasevar;

int	gvnset();

/* Function to test that list of variable names to be preserved (across TP restarts) works fine */
int main()
{
	int		status;
	ydb_buffer_t	namelist;
	ydb_tpfnptr_t	tpfn;
	ydb_string_t	zwrarg;

	/* Initialize varname, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);

	tpfn = &gvnset;
	YDB_STRLIT_TO_BUFFER(&namelist, "x,y");
	status = ydb_tp_s(NULL, &namelist, tpfn, NULL);
	assert(YDB_OK == status);
	YDB_STRLIT_TO_BUFFER(&namelist, "x,y,z");
	status = ydb_tp_s(NULL, &namelist, tpfn, NULL);
	assert(YDB_OK == status);
	YDB_STRLIT_TO_BUFFER(&namelist, "x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20,x21,x22,x23,x24,x25,x26,x27,x28,x29,x30,x31,x32,x33,x34,x35,x36,x37,x38,x39,x40,x41,x42,x43,x44,x45,x46,x47,x48,x49,x50");
	status = ydb_tp_s(NULL, &namelist, tpfn, NULL);
	assert(YDB_OK == status);
	YDB_STRLIT_TO_BUFFER(&namelist, "*");
	status = ydb_tp_s(NULL, &namelist, tpfn, NULL);
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
