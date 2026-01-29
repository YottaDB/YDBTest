/****************************************************************
 *								*
 * Copyright (c) 2019-2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "ydb474.h"

int main(void)
{
	int		i, status, done;
	ydb_buffer_t	variable, subscripts[YDB_MAX_SUBS], data;
	ydb_string_t	json_input = {0}, json_output = {0};
	char		errbuf[YDB_MAX_ERRORMSG], *json_large_buffer, *buf_addr;
	char		*json_object = "{\"\": \"root\", \"key\": \"value\", \"anotherKey\": \"anotherValue\"}";
	char		*json_array = "[\"Score\", 1.7, 42, 3.1, 7.4, 0.5, 8.8, 6, 5.4]";
	char		*json_object_max_depth = "{\"one\": {\"2\": {\"three\": {\"4\": {\"five\": {\"6\": {\"seven\": {\"8\": {\"nine\": {\"10\": {\"eleven\": {\"12\": {\"thirteen\": {\"14\": {\"fifteen\": {\"16\": {\"seventeen\": {\"18\": {\"nineteen\": {\"20\": {\"twentyone\": {\"22\": {\"twentythree\": {\"24\": {\"twentyfive\": {\"26\": {\"twentyseven\": {\"28\": {\"twentynine\": {\"30\": {\"thirtyone\": \"subscripts for this string.\"}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";
	char		*json_object_array_max_depth = "{\"1\": {\"2\": {\"3\": {\"4\": {\"5\": {\"6\": {\"7\": {\"8\": {\"9\": {\"10\": {\"11\": {\"12\": {\"13\": {\"14\": {\"15\": {\"16\": {\"17\": {\"18\": {\"19\": {\"20\": {\"21\": {\"22\": {\"23\": {\"24\": {\"25\": {\"26\": {\"27\": {\"28\": {\"29\": {\"30\": {\"array\": [1, 2, 3]}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";
	char		*json_array_over_max_size = "[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]";
	char		*json_true_false_null = "{\"ThisIsTrue\": true, \"ThisIsNull\": null, \"ThisIsFalse\": false, \"trueString\": \"true\", \"nullString\": \"null\", \"falseString\": \"false\"}";
	char		*json_too_many_subscripts = "{\"one\": {\"two\": {\"three\": {\"four\": {\"five\": {\"six\": {\"seven\": {\"eight\": {\"nine\": {\"ten\": {\"eleven\": {\"twelve\": {\"thirteen\": {\"fourteen\": {\"fifteen\": {\"sixteen\": {\"seventeen\": {\"eighteen\": {\"nineteen\": {\"twenty\": {\"twentyone\": {\"twentytwo\": {\"twentythree\": {\"twentyfour\": {\"twentyfive\": {\"twentysix\": {\"twentyseven\": {\"twentyeight\": {\"twentynine\": {\"thirty\": {\"thirtyone\": {\"thirtytwo\": \"subscripts for this string.\"}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";
	char		*json_data_and_children = "{\"Population\": {\"Belgium\": 13670000, \"Thailand\": 84140000, \"USA\": {\"\": 325737000, \"17900802\": 3929326, \"18000804\": 5308483, \"20100401\": 308745538}}, \"Capital\": {\"Belgium\": \"Brussels\", \"Thailand\": \"Bangkok\", \"USA\": \"Washington,DC\"}}";
	char		*json_invalid = "\"Life, the universe, and everything\"";
	char		*json_long_key_buffer = "{\"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\": \"y\"}";
	char		*json_long_value_buffer = "{\"x\": \"yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy\"}";
	const char	*format = "JSON";

	printf("### Test decodes of JSON data in to M global arrays in ydb_decode_st() ###\n");
	fflush(stdout);
	printf("## Decode the test JSON strings and files into M arrays ##\n");
	fflush(stdout);
	printf("# Initialize SimpleThreadAPI\n");
	fflush(stdout);
	/* Allocate buffers needed for decoding */
	YDB_MALLOC_BUFFER(&variable, YDB_MAX_IDENT);
	for (i = 0; i < YDB_MAX_SUBS; i++)
		YDB_MALLOC_BUFFER(&subscripts[i], YDB_MAX_STR);
	/* Allocate buffers needed for encoding */
	json_large_buffer = read_json_file("./ydb474_large.json");
	YDB_ASSERT(NULL != json_large_buffer);
	status = ydb_init();
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: ydb_init() [%s:%d] : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON object with too few subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonObject", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_object;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, -1, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode JSON object\n");
	fflush(stdout);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON array\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonArray", &variable, done);
	YDB_ASSERT(done);
	YDB_COPY_LITERAL_TO_BUFFER("object", &subscripts[0], done);
	YDB_ASSERT(done);
	YDB_COPY_LITERAL_TO_BUFFER("key", &subscripts[1], done);
	YDB_ASSERT(done);
	json_input.address = json_array;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 2, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON array with len_alloc < len_used for at least 1 subscript in subsarray\n");
	fflush(stdout);
	subscripts[0].len_alloc = subscripts[0].len_used - 1;
	json_input.address = json_object;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 1, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	subscripts[0].len_alloc = YDB_MAX_STR;
	printf("# Decode JSON array with len_used is non-zero and buf_addr is NULL for at least 1 subscript in subsarray\n");
	fflush(stdout);
	buf_addr = subscripts[1].buf_addr;
	subscripts[1].buf_addr = NULL;
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 2, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	subscripts[1].buf_addr = buf_addr;
	printf("# Decode JSON object with max depth\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonObjectMaxDepth", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_object_max_depth;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON object with array of max depth\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonObjectArrayMaxDepth", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_object_array_max_depth;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode JSON array over max size\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonArrayOverMaxSize", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_array_over_max_size;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, YDB_MAX_SUBS, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
	        ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
	        printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
	        fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode JSON object with a single empty key, copied in to a subtree with max subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonObjectEmptyKeyMaxSubs", &variable, done);
	YDB_ASSERT(done);
	for (i = 2; i < YDB_MAX_SUBS; i++)
	{
		char sub[3];

		sprintf(sub, "%d", i + 1);
		YDB_COPY_STRING_TO_BUFFER(sub, &subscripts[i], done);
		YDB_ASSERT(done);
	}
	json_input.address = "{\"\": \"value\"}";
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, YDB_MAX_SUBS, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON object with true, false, and null values\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonTrueFalseNull", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_true_false_null;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON that would need too many subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonTooManySubscripts", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_too_many_subscripts;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode JSON that includes nodes with both a value and a subtree\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonDataAndChildren", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_data_and_children;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode invalid JSON\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonInvalid", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_invalid;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode large JSON from a file\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonLargeBuffer", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_large_buffer;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode long key JSON from a string\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonLongKeyBuffer", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_long_key_buffer;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode long value JSON from a string\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonLongValueBuffer", &variable, done);
	YDB_ASSERT(done);
	json_input.address = json_long_value_buffer;
	json_input.length = strlen(json_input.address);
	status = ydb_decode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_input);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("\n### Test encodes of M global arrays in to JSON data in ydb_encode_st() ###\n");
	fflush(stdout);
	printf("## Encode the previously decoded strings into JSON ##\n");
	fflush(stdout);
	printf("# Encode JSON object with too few subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonObject", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, -1, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	printf("# Encode JSON object with too many subscripts\n");
	fflush(stdout);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 32, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	printf("# Encode JSON object with NULL ret_value\n");
	fflush(stdout);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("The code should never get here!\n");
		fflush(stdout);
	}
	json_output.address = NULL;
	printf("# Encode JSON object with NULL ret_value->address\n");
	fflush(stdout);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	json_output.length = 1;
	printf("# Encode JSON object with ret_value->length of 1\n");
	fflush(stdout);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	free(json_output.address);
	printf("# Encode JSON object\n");
	fflush(stdout);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	free(json_output.address);
	printf("# Encode JSON array\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonArray", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 2, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	free(json_output.address);
	printf("# Encode JSON array with len_alloc < len_used for at least 1 subscript in subsarray\n");
	fflush(stdout);
	subscripts[0].len_alloc = subscripts[0].len_used - 1;
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 1, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	subscripts[0].len_alloc = YDB_MAX_STR;
	printf("# Encode JSON array with len_used is non-zero and buf_addr is NULL for at least 1 subscript in subsarray\n");
	fflush(stdout);
	buf_addr = subscripts[1].buf_addr;
	subscripts[1].buf_addr = NULL;
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 2, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	subscripts[1].buf_addr = buf_addr;
	printf("# Encode JSON object with max depth\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonObjectMaxDepth", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	free(json_output.address);
	printf("# Encode JSON object with array of max depth\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonObjectArrayMaxDepth", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	printf("# Encode JSON array over max size\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonArrayOverMaxSize", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
	        ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
	        printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
	        fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	printf("# Encode JSON object with a single empty key, copied in to a subtree with max subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonObjectEmptyKeyMaxSubs", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, YDB_MAX_SUBS, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	free(json_output.address);
	printf("# Encode JSON object with true, false, and null values\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonTrueFalseNull", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	free(json_output.address);
	printf("# Encode JSON that would need too many subscripts, so M array should be undefined\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonTooManySubscripts", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	printf("# Encode JSON that includes nodes with both a value and a subtree\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonDataAndChildren", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	free(json_output.address);
	printf("# Encode invalid JSON, so M array should be undefined\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonInvalid", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	printf("# Encode invalid M data (non UTF-8), resulting in a Jansson encode error\n");
	fflush(stdout);
	data.buf_addr = "Not a valid UTF-8 string \300";
	data.len_alloc = strlen(data.buf_addr);
	data.len_used = data.len_alloc++;	/* strlen() does not count the NUL, so we post-increment */
	ydb_set_st(YDB_NOTTP, NULL, &variable, 0, NULL, &data);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	printf("# Encode large JSON originally from a file\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonLargeBuffer", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", json_output.address);
	fflush(stdout);
	free(json_output.address);
	printf("# Encode long key JSON originally from a string\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonLongKeyBuffer", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
	printf("# Encode long value JSON originally from a string\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("^jsonLongValueBuffer", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_st(YDB_NOTTP, NULL, &variable, 0, subscripts, format, &json_output);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_st() : %s", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s", json_output.address);
		fflush(stdout);
		free(json_output.address);
	}
clean:
	/* Clean up and exit */
	YDB_FREE_BUFFER(&variable);
	for (i = 0; i < YDB_MAX_SUBS; i++)
		YDB_FREE_BUFFER(&subscripts[i]);
	free(json_large_buffer);
	printf("\n# Exit SimpleThreadAPI\n");
	fflush(stdout);
	status = ydb_exit();
	YDB_ASSERT(!status);
	return YDB_OK;
}
