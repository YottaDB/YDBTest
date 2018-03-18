/****************************************************************
 *								*
 * Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "libyottadb.h"
#include "libydberrors.h"	/* for YDB_ERR_SIMPLEAPINEST */

#include <stdio.h>

#define ERRBUF_SIZE	1024

#define BASEVAR "^basevar"
#define VALUE1	"value"

char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, badbasevar;

int simpleapinest_helper(void);

#define	CHECK_STATUS(status)					\
{								\
	YDB_ASSERT(YDB_ERR_SIMPLEAPINEST == status);		\
	if (YDB_OK != status)					\
	{							\
		ydb_zstatus(errbuf, ERRBUF_SIZE);		\
		printf("[Line %d]: %s\n", __LINE__, errbuf);	\
		fflush(stdout);					\
	}							\
}

int simpleapinest_helper(void)
{
	int		status;
	unsigned int	data_value;
	int		dst_used;

	printf("# In external call C program. Now try ydb_*_s() calls to try SIMPLEAPINEST error#\n"); fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	status = ydb_set_s(&basevar, 0, NULL, &value1); CHECK_STATUS(status);
	status = ydb_get_s(&basevar, 0, NULL, &value1); CHECK_STATUS(status);
	status = ydb_data_s(&basevar, 0, NULL, &data_value); CHECK_STATUS(status);
	status = ydb_subscript_next_s(&basevar, 0, NULL, &value1); CHECK_STATUS(status);
	status = ydb_subscript_previous_s(&basevar, 0, NULL, &value1); CHECK_STATUS(status);
	status = ydb_node_next_s(&basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS(status);
	status = ydb_node_previous_s(&basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS(status);
	status = ydb_lock_decr_s(&basevar, 0, NULL); CHECK_STATUS(status);
	status = ydb_lock_incr_s(1000000, &basevar, 0, NULL); CHECK_STATUS(status);
	status = ydb_lock_s(1000000, 0); CHECK_STATUS(status);
	status = ydb_tp_s((ydb_tpfnptr_t)NULL, NULL, NULL, 0, NULL); CHECK_STATUS(status);
	status = ydb_delete_s(&basevar, 0, NULL, YDB_DEL_NODE); CHECK_STATUS(status);
	status = ydb_incr_s(&basevar, 0, NULL, NULL, &value1); CHECK_STATUS(status);
	status = ydb_delete_excl_s(0, NULL); CHECK_STATUS(status);
	status = ydb_zwr2str_s(NULL, NULL); CHECK_STATUS(status);
	status = ydb_str2zwr_s(NULL, NULL); CHECK_STATUS(status);
	return status;
}
