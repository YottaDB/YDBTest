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

#define ERRBUF_SIZE	1024

#define BASEVAR "basevar"
#define SUBSCR 	"1"
#define	LEN_USED_RANDOM_VALUE	10

void	check_ret_value(char *fn_name, int status, ydb_buffer_t *ret_value)
{
	if (YDB_ERR_NODEEND == status)
		printf("%s() returned YDB_ERR_NODEEND as expected\n", fn_name);
	else
		printf("%s() returned the wrong value: %d : Expecting YDB_ERR_NODEEND (%d) \n", fn_name, status, YDB_ERR_NODEEND);
	if (LEN_USED_RANDOM_VALUE == ret_value->len_used)
		printf("%s() left ret_value->len_used untouched as expected\n", fn_name);
	else
	{
		ret_value->buf_addr[ret_value->len_used] = '\0';
		printf("%s() incorrectly modified ret_value->len_used : Actual = %d : Expected = %d : ret_value->buf_addr = : %s\n",
				fn_name, ret_value->len_used, LEN_USED_RANDOM_VALUE, ret_value->buf_addr);
	}
	fflush(stdout);
}

int main(void)
{
	int		status;
	ydb_buffer_t	basevar, subscr, ret_value;
	char		errbuf[ERRBUF_SIZE], nextvarbuff[64], retvaluebuff[64];

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(SUBSCR, &subscr);

	ret_value.buf_addr = &retvaluebuff[0];
	ret_value.len_used = LEN_USED_RANDOM_VALUE;	/* a random value */
	ret_value.len_alloc = sizeof(retvaluebuff);

	printf("\n# Test that ydb_subscript_next_s() with nonexistent local variable with 1 subscript returns an empty string\n");
	status = ydb_subscript_next_s(&basevar, 1, &subscr, &ret_value);
	check_ret_value("ydb_subscript_next_s", status, &ret_value);

	printf("\n# Test that ydb_subscript_previous_s() with nonexistent local variable with 1 subscript returns an empty string\n");
	status = ydb_subscript_previous_s(&basevar, 1, &subscr, &ret_value);
	check_ret_value("ydb_subscript_previous_s", status, &ret_value);

	printf("\n# Test that ydb_subscript_next_s() with nonexistent local variable with 0 subscripts returns an empty string\n");
	status = ydb_subscript_next_s(&basevar, 0, NULL, &ret_value);
	check_ret_value("ydb_subscript_next_s", status, &ret_value);

	printf("\n# Test that ydb_subscript_previous_s() with nonexistent local variable with 0 subscripts returns an empty string\n");
	status = ydb_subscript_previous_s(&basevar, 0, NULL, &ret_value);
	check_ret_value("ydb_subscript_previous_s", status, &ret_value);
	return YDB_OK;
}
