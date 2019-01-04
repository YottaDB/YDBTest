/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.*
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

#define ERRBUF_SIZE	1024

#define BASEVAR "^baselv"
#define VALUE1	"TP with transid"

char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, badbasevar;

int	gvnset();

/* Function to test TID specified in ydb_tp_st() is honored (by finally going into TCOM record in journal file) */
int main()
{
	int		status;
	ydb_buffer_t	tid;
	ydb_tp2fnptr_t	tpfn;
	ydb_string_t	zwrarg;

	/* Initialize varname, and value buffers (needed by later "gvnset" invocation inside "ydb_tp_s" */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	tpfn = &gvnset;
	/* TID = "BA" */
	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, "BA", 0, NULL);
	YDB_ASSERT(YDB_OK == status);
	/* TID = "CS" */
	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, "CS", 0, NULL);
	YDB_ASSERT(YDB_OK == status);
	/* TID = "arbitrary str" */
	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, "any str", 0, NULL);
	YDB_ASSERT(YDB_OK == status);
	/* TID = "verylongstr" : Test that TID gets truncated to 8 bytes if input is longer than 8 bytes */
	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, "verylongstr", 0, NULL);
	YDB_ASSERT(YDB_OK == status);
	return YDB_OK;
}

/* Function to set a global variable */
int gvnset(uint64_t tptoken, ydb_buffer_t *errstr)
{
	int		status;

	/* Set a base variable, no subscripts */
	status = ydb_set_st(tptoken, errstr, &basevar, 0, NULL, &value1);
	YDB_ASSERT(YDB_OK == status);
	return YDB_OK;
}
