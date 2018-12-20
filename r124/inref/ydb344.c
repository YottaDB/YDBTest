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

#include <stdio.h>

#define ERRBUF_SIZE	1024

#define BASEVAR "basevar"
#define VALUE1	"value"


char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, value2, badbasevar;

int main(void);

#define	CHECK_STATUS(status)					\
{								\
	if ((YDB_OK != status) && (YDB_ERR_NODEEND != status))	\
	{							\
		ydb_zstatus(errbuf, ERRBUF_SIZE);		\
		printf("[Line %d]: %s\n", __LINE__, errbuf);	\
		fflush(stdout);					\
	}							\
}

int main(void)
{
	int		status;
	unsigned int	data_value;
	int		dst_used;
	char		valuebuff[64];
	int		i;

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	value2.buf_addr = &valuebuff[0];
	value2.len_used = 0;
	value2.len_alloc = sizeof(valuebuff);

	printf("Calling all ydb_s() functions twice in a loop to ensure no ydb_s() call causes a SIMPLEAPINEST error in any other subsequent ydb*_s() call.\n");

	for(i = 1; i < 3; i++)
	{
		printf("Executing iteration %d\n",i);
		printf("Calling ydb_set_s()\n");
		status = ydb_set_s(&basevar, 0, NULL, &value1); CHECK_STATUS(status);

		printf("Calling ydb_zwr2str_s()\n");
		status = ydb_zwr2str_s(&value1, &value2); CHECK_STATUS(status);

		printf("Calling ydb_get_s()\n");
		status = ydb_get_s(&basevar, 0, NULL, &value2); CHECK_STATUS(status);

		printf("Calling ydb_data_s()\n");
		status = ydb_data_s(&basevar, 0, NULL, &data_value); CHECK_STATUS(status);

		printf("Calling ydb_subscript_next_s()\n");
		status = ydb_subscript_next_s(&basevar, 0, NULL, &value1); CHECK_STATUS(status);

		printf("Calling ydb_subscript_previous_s()\n");
		status = ydb_subscript_previous_s(&basevar, 0, NULL, &value1); CHECK_STATUS(status);

		printf("Calling ydb_node_next_s()\n");
		status = ydb_node_next_s(&basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS(status);

		printf("Calling ydb_node_previous_s()\n");
		status = ydb_node_previous_s(&basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS(status);

		printf("Calling ydb_lock_s()\n");
		status = ydb_lock_s(1000000, 0); CHECK_STATUS(status);

		printf("Calling ydb_delete_s()\n");
		status = ydb_delete_s(&basevar, 0, NULL, YDB_DEL_NODE); CHECK_STATUS(status);

		printf("Calling ydb_incr_s()\n");
		status = ydb_incr_s(&basevar, 0, NULL, NULL, &value2); CHECK_STATUS(status);

		printf("Calling ydb_delete_excl_s()\n");
		status = ydb_delete_excl_s(0, NULL); CHECK_STATUS(status);

		printf("Calling ydb_str2zwr_s()\n");
		status = ydb_str2zwr_s(&value1, &value2); CHECK_STATUS(status);
	}

	printf("All SimpleApi have executed successfully");
	return status;
}
