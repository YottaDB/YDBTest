/****************************************************************
 *								*
 * Copyright (c) 2019-2025 YottaDB LLC and/or its subsidiaries.	*
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
	char		errbuf[YDB_MAX_ERRORMSG], *json_large_buffer, *json_long_keyvalue_buffer, *buf_addr;
	const char	*json_object = "{\"\": \"root\", \"key\": \"value\", \"anotherKey\": \"anotherValue\"}";
	const char	*json_array = "[\"Score\", 1.7, 42, 3.1, 7.4, 0.5, 8.8, 6, 5.4]";
	const char	*json_object_max_depth = "{\"one\": {\"2\": {\"three\": {\"4\": {\"five\": {\"6\": {\"seven\": {\"8\": {\"nine\": {\"10\": {\"eleven\": {\"12\": {\"thirteen\": {\"14\": {\"fifteen\": {\"16\": {\"seventeen\": {\"18\": {\"nineteen\": {\"20\": {\"twentyone\": {\"22\": {\"twentythree\": {\"24\": {\"twentyfive\": {\"26\": {\"twentyseven\": {\"28\": {\"twentynine\": {\"30\": {\"thirtyone\": \"subscripts for this string.\"}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";
	const char	*json_array_after_max_depth = "{\"1\": {\"2\": {\"3\": {\"4\": {\"5\": {\"6\": {\"7\": {\"8\": {\"9\": {\"10\": {\"11\": {\"12\": {\"13\": {\"14\": {\"15\": {\"16\": {\"17\": {\"18\": {\"19\": {\"20\": {\"21\": {\"22\": {\"23\": {\"24\": {\"25\": {\"26\": {\"27\": {\"28\": {\"29\": {\"30\": {\"array\": [1, 2, 3]}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";
	const char	*json_true_false_null = "{\"ThisIsTrue\": true, \"ThisIsNull\": null, \"ThisIsFalse\": false, \"trueString\": \"true\", \"nullString\": \"null\", \"falseString\": \"false\"}";
	const char	*json_too_many_subscripts = "{\"one\": {\"two\": {\"three\": {\"four\": {\"five\": {\"six\": {\"seven\": {\"eight\": {\"nine\": {\"ten\": {\"eleven\": {\"twelve\": {\"thirteen\": {\"fourteen\": {\"fifteen\": {\"sixteen\": {\"seventeen\": {\"eighteen\": {\"nineteen\": {\"twenty\": {\"twentyone\": {\"twentytwo\": {\"twentythree\": {\"twentyfour\": {\"twentyfive\": {\"twentysix\": {\"twentyseven\": {\"twentyeight\": {\"twentynine\": {\"thirty\": {\"thirtyone\": {\"thirtytwo\": \"subscripts for this string.\"}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}";
	const char	*json_data_and_children = "{\"Population\": {\"Belgium\": 13670000, \"Thailand\": 84140000, \"USA\": {\"\": 325737000, \"17900802\": 3929326, \"18000804\": 5308483, \"20100401\": 308745538}}, \"Capital\": {\"Belgium\": \"Brussels\", \"Thailand\": \"Bangkok\", \"USA\": \"Washington,DC\"}}";
	const char	*json_invalid= "\"Life, the universe, and everything\"";
	const char	*format = "JSON";

	printf("### Test decodes of JSON data in to M local arrays in ydb_decode_s() ###\n");
	fflush(stdout);
	printf("## Decode the test JSON strings and files into M arrays ##\n");
	fflush(stdout);
	printf("# Initialize SimpleAPI\n");
	fflush(stdout);
	/* Allocate buffers needed for decoding */
	YDB_MALLOC_BUFFER(&variable, YDB_MAX_IDENT);
	for (i = 0; i < YDB_MAX_SUBS; i++)
		YDB_MALLOC_BUFFER(&subscripts[i], YDB_MAX_STR);
	/* Allocate buffers needed for encoding */
	YDB_MALLOC_BUFFER(&data, YDB_MAX_STR);
	json_large_buffer = read_json_file("./ydb474_large.json");
	YDB_ASSERT(NULL != json_large_buffer);
	json_long_keyvalue_buffer = read_json_file("./ydb474_long_keyvalue.json");
	YDB_ASSERT(NULL != json_long_keyvalue_buffer);
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
	YDB_COPY_LITERAL_TO_BUFFER("jsonObject", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, -1, subscripts, format, json_object);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode JSON object\n");
	fflush(stdout);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_object);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON array\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonArray", &variable, done);
	YDB_ASSERT(done);
	YDB_COPY_LITERAL_TO_BUFFER("object", &subscripts[0], done);
	YDB_ASSERT(done);
	YDB_COPY_LITERAL_TO_BUFFER("key", &subscripts[1], done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 2, subscripts, format, json_array);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON array with len_alloc < len_used for at least 1 subscript in subsarray\n");
	fflush(stdout);
	subscripts[0].len_alloc = subscripts[0].len_used - 1;
	status = ydb_decode_s(&variable, 1, subscripts, format, json_object);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	subscripts[0].len_alloc = YDB_MAX_STR;
	printf("# Decode JSON array with len_used is non-zero and buf_addr is NULL for at least 1 subscript in subsarray\n");
	fflush(stdout);
	buf_addr = subscripts[1].buf_addr;
	subscripts[1].buf_addr = NULL;
	status = ydb_decode_s(&variable, 2, subscripts, format, json_object);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	subscripts[1].buf_addr = buf_addr;
	printf("# Decode JSON object with max depth\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonObjectMaxDepth", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_object_max_depth);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON array after max depth\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonArrayAfterMaxDepth", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_array_after_max_depth);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode JSON object with a single empty key, copied in to a subtree with max subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonObjectEmptyKeyMaxSubs", &variable, done);
	YDB_ASSERT(done);
	for (i = 2; i < YDB_MAX_SUBS; i++)
	{
		char sub[3];

		sprintf(sub, "%d", i + 1);
		YDB_COPY_STRING_TO_BUFFER(sub, &subscripts[i], done);
		YDB_ASSERT(done);
	}
	status = ydb_decode_s(&variable, YDB_MAX_SUBS, subscripts, format, "{\"\": \"value\"}");
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON object with true, false, and null values\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonTrueFalseNull", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_true_false_null);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode JSON that would need too many subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonTooManySubscripts", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_too_many_subscripts);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode JSON that includes nodes with both a value and a subtree\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonDataAndChildren", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_data_and_children);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode invalid JSON\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonInvalid", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_invalid);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	printf("# Decode large JSON from a file\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonLargeBuffer", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_large_buffer);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("# Decode long key/value JSON from a file\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonLongKeyValueBuffer", &variable, done);
	YDB_ASSERT(done);
	status = ydb_decode_s(&variable, 0, subscripts, format, json_long_keyvalue_buffer);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_decode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("\n### Test encodes of M local arrays in to JSON data in ydb_encode_s() ###\n");
	fflush(stdout);
	printf("## Encode the previously decoded strings into JSON ##\n");
	fflush(stdout);
	printf("# Encode JSON object with too few subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonObject", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, -1, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	printf("# Encode JSON object with too many subscripts\n");
	fflush(stdout);
	status = ydb_encode_s(&variable, 32, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	printf("# Encode JSON object with NULL ret_value\n");
	fflush(stdout);
	status = ydb_encode_s(&variable, 0, subscripts, format, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	printf("# Encode JSON object with NULL ret_value->buf_addr\n");
	fflush(stdout);
	buf_addr = data.buf_addr;
	data.buf_addr = NULL;
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	data.buf_addr = buf_addr;
	printf("# Encode JSON object with insufficient string length for encoded data\n");
	fflush(stdout);
	buf_addr = data.buf_addr;
	data.len_alloc = 0;
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	data.len_alloc = YDB_MAX_STR;
	printf("# Encode JSON object\n");
	fflush(stdout);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", data.buf_addr);
	fflush(stdout);
	data.len_used = 0;
	printf("# Encode JSON array\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonArray", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 2, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", data.buf_addr);
	fflush(stdout);
	data.len_used = 0;
	printf("# Encode JSON array with len_alloc < len_used for at least 1 subscript in subsarray\n");
	fflush(stdout);
	subscripts[0].len_alloc = subscripts[0].len_used - 1;
	status = ydb_encode_s(&variable, 1, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	subscripts[0].len_alloc = YDB_MAX_STR;
	data.len_used = 0;
	printf("# Encode JSON array with len_used is non-zero and buf_addr is NULL for at least 1 subscript in subsarray\n");
	fflush(stdout);
	buf_addr = subscripts[1].buf_addr;
	subscripts[1].buf_addr = NULL;
	status = ydb_encode_s(&variable, 2, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	subscripts[1].buf_addr = buf_addr;
	data.len_used = 0;
	printf("# Encode JSON object with max depth\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonObjectMaxDepth", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", data.buf_addr);
	fflush(stdout);
	data.len_used = 0;
	printf("# Encode JSON array after max depth\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonArrayAfterMaxDepth", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	data.len_used = 0;
	printf("# Encode JSON object with a single empty key, copied in to a subtree with max subscripts\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonObjectEmptyKeyMaxSubs", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, YDB_MAX_SUBS, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", data.buf_addr);
	fflush(stdout);
	data.len_used = 0;
	printf("# Encode JSON object with true, false, and null values\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonTrueFalseNull", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", data.buf_addr);
	fflush(stdout);
	data.len_used = 0;
	printf("# Encode JSON that would need too many subscripts, so M array should be undefined\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonTooManySubscripts", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	data.len_used = 0;
	printf("# Encode JSON that includes nodes with both a value and a subtree\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonDataAndChildren", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", data.buf_addr);
	fflush(stdout);
	data.len_used = 0;
	data.len_alloc = 100;
	printf("# Encode JSON that includes nodes with both a value and a subtree with a buffer that's too small\n");
	fflush(stdout);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	data.len_used = 0;
	data.len_alloc = YDB_MAX_STR;
	printf("# Encode invalid JSON, so M array should be undefined\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonInvalid", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	data.len_used = 0;
	printf("# Encode invalid M data (non UTF-8), resulting in a Jansson encode error\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("Not a valid UTF-8 string \300", &data, done);
	YDB_ASSERT(done);
	ydb_set_s(&variable, 0, NULL, &data);
	data.len_used = 0;
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		/* No goto here because we expect this to fail and the rest of the tests should still run */
	}
	else
	{
		printf("%s\n", data.buf_addr);
		fflush(stdout);
	}
	data.len_used = 0;
	printf("# Encode large JSON originally from a file\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonLargeBuffer", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s\n", data.buf_addr);
	fflush(stdout);
	data.len_used = 0;
	printf("# Encode long key/value JSON originally from a file\n");
	fflush(stdout);
	YDB_COPY_LITERAL_TO_BUFFER("jsonLongKeyValueBuffer", &variable, done);
	YDB_ASSERT(done);
	status = ydb_encode_s(&variable, 0, subscripts, format, &data);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, YDB_MAX_ERRORMSG);
		printf("Error: %s:%d: ydb_encode_s() : %s\n", __FILE__, __LINE__, errbuf);
		fflush(stdout);
		goto clean;
	}
	printf("%s", data.buf_addr);
	fflush(stdout);
clean:
	/* Clean up and exit */
	YDB_FREE_BUFFER(&variable);
	for (i = 0; i < YDB_MAX_SUBS; i++)
		YDB_FREE_BUFFER(&subscripts[i]);
	YDB_FREE_BUFFER(&data);
	free(json_large_buffer);
	free(json_long_keyvalue_buffer);
	printf("\n# Exit SimpleAPI\n");
	fflush(stdout);
	status = ydb_exit();
	YDB_ASSERT(!status);
	return YDB_OK;
}
