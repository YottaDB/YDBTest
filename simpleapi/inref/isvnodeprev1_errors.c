/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	*
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

#define BASEVAR	"$ZGBLDIR"

int main()
{
	int		status, i;
	ydb_buffer_t	basevar, ret_value;
	char		errbuf[ERRBUF_SIZE];
	char		retvaluebuff[64];

	printf("### Test error scenarios in ydb_node_previous_s() of Intrinsic Special Variables ###\n\n"); fflush(stdout);
	/* Initialize varname and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	ret_value.buf_addr = retvaluebuff;
	ret_value.len_alloc = sizeof(retvaluebuff);
	ret_value.len_used = 0;

	printf("# Attempting ydb_node_previous_s() of ISV should issue UNIMPLOP error\n"); fflush(stdout);
	status = ydb_node_previous_s(&basevar, 0, NULL, &i, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_node_previous_s() [a]: %s\n", errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
