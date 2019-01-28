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
#include <string.h>
#include <stdio.h>

#define ERRBUF_SIZE 	1024

#define VALUE		"test"
#define LONGVAR		"^toolong"

char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, value2;

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

int main ()
{
	int 		status, dst_used;
	unsigned int	data_value;
	char		valuebuff[64];

	YDB_LITERAL_TO_BUFFER(LONGVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE, &value1);

	value2.buf_addr = &valuebuff[0];
	value2.len_used = 0;
	value2.len_alloc = sizeof(valuebuff);

	printf("\n# Calling all ydb_*_s() functions to ensure each generates a KEY2BIG error\n");

	printf("# Calling ydb_set_s()\n");
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_get_s()\n");
	status = ydb_get_s(&basevar, 0, NULL, &value2);
	CHECK_STATUS(status);

	printf("# Calling ydb_data_s()\n");
	status = ydb_data_s(&basevar, 0, NULL, &data_value);
	CHECK_STATUS(status);

	printf("# Calling ydb_subscript_next_s()\n");
	status = ydb_subscript_next_s(&basevar, 0, NULL, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_subscript_previous_s()\n");
	status = ydb_subscript_previous_s(&basevar, 0, NULL, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_node_next_s()\n");
	status = ydb_node_next_s(&basevar, 0, NULL, &dst_used, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_node_previous_s()\n");
	status = ydb_node_previous_s(&basevar, 0, NULL, &dst_used, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_delete_s()\n");
	status = ydb_delete_s(&basevar, 0, NULL, YDB_DEL_NODE);
	CHECK_STATUS(status);

	printf("# Calling ydb_incr_s()\n");
	status = ydb_incr_s(&basevar, 0, NULL, NULL, &value2);
	CHECK_STATUS(status);

	printf("All SimpleApi have been tested");
	return status;
}
