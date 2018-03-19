/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.*
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
	int		status;
	unsigned int	ret_value;
	ydb_buffer_t	basevar;
	char		errbuf[ERRBUF_SIZE];
	char		retvaluebuff[64];

	printf("### Test error scenarios in ydb_data_s() of Intrinsic Special Variables ###\n\n"); fflush(stdout);
	/* Initialize varname and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);

	printf("# Attempting ydb_data_s() of ISV should issue UNIMPLOP error\n"); fflush(stdout);
	status = ydb_data_s(&basevar, 0, NULL, &ret_value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_data_s() [a]: %s\n", errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
