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
/* Our thanks to Peter Goss (@gossrock at gitlab) who contributed this test to find the bug and to become a test */

/* Build directions:
 * gcc -c ydb480.c -I$gtm_dist
 * gcc -o ydb480 ydb480.o -Wl,-rpath,$ydb_dist -L$gtm_dist -lyottadb -lelf -lncurses -lm -ldl -lc -lpthread -lrt
 */

#include <stdio.h>
#include <string.h>

#include "libyottadb.h"

static ydb_buffer_t *empty_buffer(int length_to_allocate)
{
	ydb_buffer_t *ret_buffer;

	ret_buffer = (ydb_buffer_t *)malloc(length_to_allocate * sizeof(ydb_buffer_t));
	YDB_MALLOC_BUFFER(ret_buffer, length_to_allocate);
	return ret_buffer;
}

static ydb_buffer_t *buffer_from_string(char* string)
{
	ydb_buffer_t	*ret_buffer;
	char		*buf;

	ret_buffer = (ydb_buffer_t *)malloc(sizeof(ydb_buffer_t));
	buf = (char *)malloc(strlen(string) * sizeof(char));
	strcpy(buf, string);
	ret_buffer->len_used = ret_buffer->len_alloc = strlen(string);
	ret_buffer->buf_addr = buf;
	return ret_buffer;
}

static void set(char *varname, char *value)
{
	ydb_buffer_t	*error_buff, *varname_buff, *value_buff;
	int		status;

	printf("Setting '%s' to '%s'.\t\t\t", varname, value);
	error_buff = empty_buffer(YDB_MAX_ERRORMSG);
	varname_buff = buffer_from_string(varname);
	value_buff = buffer_from_string(value);
	status = ydb_set_st(YDB_NOTTP, error_buff, varname_buff, 0, NULL, value_buff);
	printf("set status: %d\n", status);
	YDB_FREE_BUFFER(error_buff);
	YDB_FREE_BUFFER(varname_buff);
	YDB_FREE_BUFFER(value_buff);
}

static ydb_buffer_t *get(char* varname)
{
	ydb_buffer_t	*error_buff, *varname_buff, *ret_buff;
	int		status;

	printf("Getting '%s'.\t\t\t", varname);
	error_buff = empty_buffer(YDB_MAX_ERRORMSG);
	varname_buff = buffer_from_string(varname);
	ret_buff = empty_buffer(50);
	status = ydb_get_st(YDB_NOTTP, error_buff, varname_buff, 0, NULL, ret_buff);
	printf("get status: %d\n", status);
	YDB_FREE_BUFFER(error_buff);
	YDB_FREE_BUFFER(varname_buff);
	return ret_buff;
}

static ydb_buffer_t *incr(char *varname, char *increment)
{
	ydb_buffer_t	*error_buff, *varname_buff, *incr_buff, *ret_buff;
	int		status;

	printf("Incrementing '%s' by '%s'.\t", varname, increment);
	error_buff = empty_buffer(YDB_MAX_ERRORMSG);
	varname_buff = buffer_from_string(varname);
	incr_buff = buffer_from_string(increment);
	ret_buff = empty_buffer(50);
	status = ydb_incr_st(YDB_NOTTP, error_buff, varname_buff, 0, NULL, incr_buff, ret_buff);
	printf("incr status: %d\n", status);
	YDB_FREE_BUFFER(error_buff);
	YDB_FREE_BUFFER(varname_buff);
	YDB_FREE_BUFFER(incr_buff);
	return ret_buff;
}

int main() {
	ydb_buffer_t *incr_result, *value;
	char *varname = "^test";

	set(varname, "0");
	value = get(varname);
	printf("\n'%s' is '%.*s'\n", varname, value->len_used, value->buf_addr);
	YDB_FREE_BUFFER(value);
	incr_result = incr(varname, "1000000");
	printf("increment result = '%.*s' <-----\n", incr_result-> len_used, incr_result->buf_addr);
	value = get(varname);
	printf("'%s' is '%.*s'  <-----\n", varname, value->len_used, value->buf_addr);
	return YDB_OK;
}
