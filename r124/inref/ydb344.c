/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.*
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
#include <time.h>
#include <sys/types.h>
#include <unistd.h>

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
	int             seed, use_simplethreadapi;

	/* Initialize random number seed */
	seed = (time(NULL) * getpid());
	srand48(seed);
	use_simplethreadapi = (int)(2 * drand48());
	printf("# Random choice : use_simplethreadapi = %d\n", use_simplethreadapi); fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	value2.buf_addr = &valuebuff[0];
	value2.len_used = 0;
	value2.len_alloc = sizeof(valuebuff);

	printf("Calling all ydb_*_s()/ydb_*_st() functions twice in a loop to ensure no ydb_*_s()/ydb_*_st() call causes a SIMPLEAPINEST error in any other subsequent ydb_*_s()/ydb_*_st() call.\n");

	for (i = 1; i < 3; i++)
	{
		printf("Executing iteration %d\n",i);
		printf("Calling ydb_set_s()/ydb_set_st()\n");
		status = use_simplethreadapi
				? ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1)
				: ydb_set_s(&basevar, 0, NULL, &value1);
		CHECK_STATUS(status);

		printf("Calling ydb_zwr2str_s()/ydb_zwr2str_st()\n");
		status = use_simplethreadapi
				? ydb_zwr2str_st(YDB_NOTTP, NULL, &value1, &value2)
				: ydb_zwr2str_s(&value1, &value2);
		CHECK_STATUS(status);

		printf("Calling ydb_get_s()/ydb_get_st()\n");
		status = use_simplethreadapi
				? ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value2)
				: ydb_get_s(&basevar, 0, NULL, &value2);
		CHECK_STATUS(status);

		printf("Calling ydb_data_s()/ydb_data_st()\n");
		status = use_simplethreadapi
				? ydb_data_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &data_value)
				: ydb_data_s(&basevar, 0, NULL, &data_value);
		CHECK_STATUS(status);

		printf("Calling ydb_subscript_next_s()/ydb_subscript_next_st()\n");
		status = use_simplethreadapi
				? ydb_subscript_next_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1)
				: ydb_subscript_next_s(&basevar, 0, NULL, &value1);
		CHECK_STATUS(status);

		printf("Calling ydb_subscript_previous_s()/ydb_subscript_previous_st()\n");
		status = use_simplethreadapi
				? ydb_subscript_previous_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1)
				: ydb_subscript_previous_s(&basevar, 0, NULL, &value1);
		CHECK_STATUS(status);

		printf("Calling ydb_node_next_s()/ydb_node_next_st()\n");
		status = use_simplethreadapi
				? ydb_node_next_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &dst_used, &value1)
				: ydb_node_next_s(&basevar, 0, NULL, &dst_used, &value1);
		CHECK_STATUS(status);

		printf("Calling ydb_node_previous_s()/ydb_node_previous_st()\n");
		status = use_simplethreadapi
				? ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &dst_used, &value1)
				: ydb_node_previous_s(&basevar, 0, NULL, &dst_used, &value1);
		CHECK_STATUS(status);

		printf("Calling ydb_lock_s()/ydb_lock_st()\n");
		status = use_simplethreadapi
				? ydb_lock_st(YDB_NOTTP, NULL, 1000000, 0)
				: ydb_lock_s(1000000, 0);
		CHECK_STATUS(status);

		printf("Calling ydb_delete_s()/ydb_delete_st()\n");
		status = use_simplethreadapi
				? ydb_delete_st(YDB_NOTTP, NULL, &basevar, 0, NULL, YDB_DEL_NODE)
				: ydb_delete_s(&basevar, 0, NULL, YDB_DEL_NODE);
		CHECK_STATUS(status);

		printf("Calling ydb_incr_s()/ydb_incr_st()\n");
		status = use_simplethreadapi
				? ydb_incr_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL, &value2)
				: ydb_incr_s(&basevar, 0, NULL, NULL, &value2);
		CHECK_STATUS(status);

		printf("Calling ydb_delete_excl_s()/ydb_delete_excl_st()\n");
		status = use_simplethreadapi
				? ydb_delete_excl_st(YDB_NOTTP, NULL, 0, NULL)
				: ydb_delete_excl_s(0, NULL);
		CHECK_STATUS(status);

		printf("Calling ydb_str2zwr_s()/ydb_str2zwr_st()\n");
		status = use_simplethreadapi
				? ydb_str2zwr_st(YDB_NOTTP, NULL, &value1, &value2)
				: ydb_str2zwr_s(&value1, &value2);
		CHECK_STATUS(status);
	}

	printf("All SimpleApi have executed successfully");
	return status;
}
