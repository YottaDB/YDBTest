/****************************************************************
 *								*
 * Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	*
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
#include <assert.h>

#define ERRBUF_SIZE	1024

#define VALUE 	"Life, the universe, and everything"
#define	JSON	""

int main()
{
	int		i, status, next_num_subscripts, cur_num_subscripts;
	ydb_buffer_t	subscr31[31], output, input, decode_to, subscripts_array[31], encoded_data, next_subscripts_array[1];
	ydb_string_t	zwrarg;
	char		errbuf[ERRBUF_SIZE];
	const char	*json_string = "{\"key\": \"value\"}";
	const char	*json_string2 = "[\"Score\", 1.7, 42, 3.1, 7.4, 0.5, 8.8, 6, 5.4]";
	const char	*json_string3 = "{\"one\": {\"two\": {\"three\": {\"four\": {\"five\": {\"six\": {\"seven\": {\"eight\": {\"nine\": {\"ten\": {\"eleven\": {\"twelve\": {\"thirteen\": {\"fourteen\": {\"fifteen\": {\"sixteen\": {\"seventeen\": {\"eighteen\": {\"nineteen\": {\"twenty\": {\"twentyone\": {\"twentytwo\": {\"twentythree\": {\"twentyfour\": {\"twentyfive\": {\"twentysix\": {\"twentyseven\": {\"twentyeight\": {\"twentynine\": {\"thirty\": {\"thirtyone\": \"subscripts for this string.\" }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";
	const char	*json_string4 = "{ \"ThisIsTrue\": true, \"ThisIsNull\": null, \"ThisIsFalse\": false}";
	const char	*json_string_too_many_subscripts = "{\"one\": {\"two\": {\"three\": {\"four\": {\"five\": {\"six\": {\"seven\": {\"eight\": {\"nine\": {\"ten\": {\"eleven\": {\"twelve\": {\"thirteen\": {\"fourteen\": {\"fifteen\": {\"sixteen\": {\"seventeen\": {\"eighteen\": {\"nineteen\": {\"twenty\": {\"twentyone\": {\"twentytwo\": {\"twentythree\": {\"twentyfour\": {\"twentyfive\": {\"twentysix\": {\"twentyseven\": {\"twentyeight\": {\"twentynine\": {\"thirty\": {\"thirtyone\": {\"thirtytwo\": \"subscripts for this string.\" }}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";
	const char	*json_string6 = "{ \"Population\": { \"Belgium\": 13670000, \"Thailand\": 84140000, \"USA\": {\"_root\": 325737000, \"17900802\": 3929326, \"18000804\": 5308483, \"20100401\": 308745538}}, \"Capital\": {\"Belgium\": \"Brussels\", \"Thailand\": \"Bangkok\", \"USA\": \"Washington,DC\"} }";
	const char	*value = "\"Life, the universe, and everything\"", *json="JSON";

	printf("### Test simple decodes in ydb_decode_st() of JSON objects ###\n"); fflush(stdout);
	/* Initialize varname, subscript, and value buffers */
	printf("Initialize call-in environment\n"); fflush(stdout);
	status = ydb_init();
	decode_to.len_alloc = 31;
	decode_to.buf_addr = malloc(31);
	for (i = 0; i < 31; i++)
	{
		subscr31[i].len_alloc = 31;
		subscr31[i].len_used = 0;
		subscr31[i].buf_addr = malloc(31);
	}
	if (0 != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_init: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Decode valid JSON object\n"); fflush(stdout);
	strcpy(decode_to.buf_addr, "str1");
	decode_to.len_used = 4;
	status = ydb_decode_st(YDB_NOTTP, NULL, &decode_to, 0, subscr31, 31, json, json_string);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_decode_st() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Decode valid JSON array\n"); fflush(stdout);
	strcpy(decode_to.buf_addr, "str2");
	status = ydb_decode_st(YDB_NOTTP, NULL, &decode_to, 0, subscr31, 31, json, json_string2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_decode_st() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Decode massive JSON array\n"); fflush(stdout);
	strcpy(decode_to.buf_addr, "str3");
	status = ydb_decode_st(YDB_NOTTP, NULL, &decode_to, 0, subscr31, 31, json, json_string3);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_decode_st() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Decode boolean JSON objects\n"); fflush(stdout);
	strcpy(decode_to.buf_addr, "str4");
	status = ydb_decode_st(YDB_NOTTP, NULL, &decode_to, 0, subscr31, 31, json, json_string4);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_decode_st() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("Decode invalid JSON\n"); fflush(stdout);
	strcpy(decode_to.buf_addr, "invalid");
	decode_to.len_used = 7;
	status = ydb_decode_st(YDB_NOTTP, NULL, &decode_to, 0, subscr31, 31, json, value);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_decode_st() [2]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Decode valid JSON that would need too many subscripts\n"); fflush(stdout);
	strcpy(decode_to.buf_addr, "str5");
	decode_to.len_used = 4;
	status = ydb_decode_st(YDB_NOTTP, NULL, &decode_to, 0, subscr31, 31, json, json_string_too_many_subscripts);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_decode_st() [2]: %s\n", errbuf);
		fflush(stdout);
	}
	printf("Decode valid JSON that includes nodes with both a value and a subtree\n"); fflush(stdout);
	strcpy(decode_to.buf_addr, "str6");
	decode_to.len_used = 4;
	status = ydb_decode_st(YDB_NOTTP, NULL, &decode_to, 0, subscr31, 31, json, json_string6);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_decode_st() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("### Test encodes in ydb_encode_st() using the decoded JSON objects ###\n"); fflush(stdout);
	for (i = 0; i < 31; i++)
	{
		subscripts_array[i].buf_addr = (char *) malloc(31);
		subscripts_array[i].len_alloc = 31;
		subscripts_array[i].len_used = 0;
	}
	encoded_data.len_alloc = 8425;
	encoded_data.len_used = 0;
	encoded_data.buf_addr = malloc(8425);
	cur_num_subscripts = 0;
	printf("Encode the previously decoded strings into JSON\n");
	input.buf_addr = "str1";
	input.len_alloc = 4;
	input.len_used = 4;
	assert(encoded_data.len_alloc >= encoded_data.len_used);
	for (i = 0; i < encoded_data.len_used; i++)
	{
		printf("%c", encoded_data.buf_addr[i]);
	}
	printf("\n");
	status = ydb_encode_st(YDB_NOTTP, NULL, &input, cur_num_subscripts, subscripts_array, json, &encoded_data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_encode_st() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	else
	{	for (i = 0; i < encoded_data.len_used; i++)
		{
			printf("%c", encoded_data.buf_addr[i]);
		}
	}
	printf("\n");
	input.buf_addr = "str2";
	input.len_alloc = 4;
	input.len_used = 4;
	status = ydb_encode_st(YDB_NOTTP, NULL, &input, cur_num_subscripts, subscripts_array, json, &encoded_data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_encode_st() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	else
	{	for (i = 0; i < encoded_data.len_used; i++)
		{
			printf("%c", encoded_data.buf_addr[i]);
		}
	}
	printf("\n");
	input.buf_addr = "str3";
	input.len_alloc = 4;
	input.len_used = 4;
	status = ydb_encode_st(YDB_NOTTP, NULL, &input, cur_num_subscripts, subscripts_array, json, &encoded_data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_encode_st() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	else
	{	for (i = 0; i < encoded_data.len_used; i++)
		{
			printf("%c", encoded_data.buf_addr[i]);
		}
	}
	printf("\n");
	input.buf_addr = "str4";
	input.len_alloc = 4;
	input.len_used = 4;
	status = ydb_encode_st(YDB_NOTTP, NULL, &input, cur_num_subscripts, subscripts_array, json, &encoded_data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_encode_st() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	else
	{	for (i = 0; i < encoded_data.len_used; i++)
		{
			printf("%c", encoded_data.buf_addr[i]);
		}
	}
	printf("\n");
	input.buf_addr = "str5";
	input.len_alloc = 4;
	input.len_used = 4;
	status = ydb_encode_st(YDB_NOTTP, NULL, &input, cur_num_subscripts, subscripts_array, json, &encoded_data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_encode_st() [2]: %s\n", errbuf);
		fflush(stdout);
	}
	else
	{	for (i = 0; i < encoded_data.len_used; i++)
		{
			printf("%c", encoded_data.buf_addr[i]);
		}
	}
	printf("\n");
	input.buf_addr = "str6";
	input.len_alloc = 4;
	input.len_used = 4;
	status = ydb_encode_st(YDB_NOTTP, NULL, &input, cur_num_subscripts, subscripts_array, json, &encoded_data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_encode_st() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	else
	{	for (i = 0; i < encoded_data.len_used; i++)
		{
			printf("%c", encoded_data.buf_addr[i]);
		}
	}
	printf("\n");
	for (i = 0; i < 31; i++)
	{
		free(subscripts_array[i].buf_addr);
		free(subscr31[i].buf_addr);
	}
	free(encoded_data.buf_addr);
	return YDB_OK;
}
