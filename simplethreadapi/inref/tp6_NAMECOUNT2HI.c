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
#include "libydberrors.h"	/* for YDB_ERR_LVUNDEF */

#include <stdio.h>
#include <time.h>	/* needed for "time" */
#include <unistd.h>	/* needed for "getpid" */

#define BASEVAR 	"^tp3"
#define VALUE1		"TP with comma-separated list of variable names to be preserved"
#define ERRBUF_SIZE	1024

char		errbuf[ERRBUF_SIZE];

ydb_buffer_t	basevar, value1, x0var, x1var, x2var, starvar;
ydb_buffer_t	varnames[YDB_MAX_NAMES + 1];

int	gvnset();

int main()
{
	int		status, i;
	ydb_string_t	zwrarg;
	char		sprintfbuff[1024], *spfbufptr;

	printf("### Test NAMECOUNT2HI error ###\n");
	fflush(stdout);

	/* Initialize varname, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	for (i = 0, spfbufptr = sprintfbuff; YDB_MAX_NAMES >= i; i++)
	{	/* Generate ydb_buff_t for each of x0, x1, x2, ... xN where N is YDB_MAX_NAMES */
		varnames[i].buf_addr = spfbufptr;
		varnames[i].len_used = varnames[i].len_alloc = sprintf(spfbufptr, "x%i", i);
		spfbufptr += varnames[i].len_used;
	}
	status = ydb_tp_st(YDB_NOTTP, NULL, &gvnset, NULL, NULL, YDB_MAX_NAMES + 1, (ydb_buffer_t *)&varnames);
	YDB_ASSERT(YDB_OK != status);
	ydb_zstatus(errbuf, ERRBUF_SIZE);
	printf("ydb_tp_st() : Exit Status = %d : Exit string = %s\n", status, errbuf);
	fflush(stdout);
	return YDB_OK;
}

/* Function to set a global variable */
int gvnset(uint64_t tptoken, ydb_buffer_t *errstr)
{
	int		status;

	/* Set a base variable, no subscripts */
	status = ydb_set_st(tptoken, errstr, &basevar, 0, NULL, &value1);
	return status;
}
