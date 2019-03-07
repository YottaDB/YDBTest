/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	*
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
#define BASEVAR		"^ok"
#define SUBSCR		"1"
char		errbuf[ERRBUF_SIZE];
ydb_buffer_t	basevar, value1, value2, subscr[4];

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
	int 		status, i, dst_used;
	unsigned int	data_value;
	char		valuebuff[64];

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE, &value1);

	value2.buf_addr = &valuebuff[0];
	value2.len_used = 0;
	value2.len_alloc = sizeof(valuebuff);

	/* Initialize subscr ydb_buffer_t */

	for (i = 0; i < 4; i++)
		YDB_LITERAL_TO_BUFFER(SUBSCR, &subscr[i])

	printf("\n# Calling all ydb_*_st() functions to ensure each generates a GVSUBOFLOW error\n");

	printf("# Calling ydb_set_st()\n");
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 4, subscr, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_get_st()\n");
	status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 4, subscr, &value2);
	CHECK_STATUS(status);

	printf("# Calling ydb_data_st()\n");
	status = ydb_data_st(YDB_NOTTP, NULL, &basevar, 4, subscr, &data_value);
	CHECK_STATUS(status);

	printf("# Calling ydb_subscript_next_st()\n");
	status = ydb_subscript_next_st(YDB_NOTTP, NULL, &basevar, 4, subscr, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_subscript_previous_st()\n");
	status = ydb_subscript_previous_st(YDB_NOTTP, NULL, &basevar, 4, subscr, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_node_next_st()\n");
	status = ydb_node_next_st(YDB_NOTTP, NULL, &basevar, 4, subscr, &dst_used, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_node_previous_st()\n");
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 4, subscr, &dst_used, &value1);
	CHECK_STATUS(status);

	printf("# Calling ydb_delete_st()\n");
	status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, 4, subscr, YDB_DEL_NODE);
	CHECK_STATUS(status);

	printf("# Calling ydb_incr_st()\n");
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 4, subscr, NULL, &value2);
	CHECK_STATUS(status);

	printf("All SimpleApi have been tested");
	return status;
}
