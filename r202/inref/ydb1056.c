/****************************************************************
*
* Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.
* All rights reserved.
*
* This source code contains the intellectual property
* of its copyright holder(s), and is made available
* under a license.  If you do not know the terms of
* the license, please stop and do not read further.
*
****************************************************************/

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <libyottadb.h>

// python -c "print('1234567890' * 10)"
static char s[100] = "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890";

void o_repeatb(int argc, ydb_buffer_t *buf, ydb_int_t extra) {
	if (!argc) return;
	if (argc == 2) {
		assert(buf->len_used == 0);
		assert(buf->len_alloc == 0);
		assert(buf->buf_addr == NULL);
		printf("o_repeatb: no input argument passed\n");
		return;
	}
	assert(buf->len_used == 0);
	assert(buf->len_alloc == 100);
	assert(buf->buf_addr != NULL);
	memcpy(buf->buf_addr, s, 100);
	buf->len_used = 100;
}

void o_repeats(int argc, ydb_string_t *buf, ydb_int_t extra) {
	if (!argc) return;
	if (argc == 2) {
		assert(buf->length == 0);
		assert(buf->address == NULL);
		printf("o_repeats: no input argument passed\n");
		return;
	}
	// NOTE: this is the allocation size, not the input size. there is no input for O parameters.
	assert(buf->length == 100);
	assert(buf->address != NULL && "unreachable; if an argument is present it should have a buffer allocated");
	memcpy(buf->address, s, 100);
	buf->length = 100;
}
void o_repeatc(int argc, ydb_char_t *buf, ydb_int_t extra) {
	if (!argc) return;
	assert(buf != NULL);
	if (argc == 2)
		assert(*buf == '\0');
	if (*buf == '\0')
		printf("o_repeatc: empty string or no input argument\n");
	// NOTE: we can copy one fewer byte because we need to reserve space for the null terminator.
	memcpy(buf, s, 99);
	buf[99] = '\0';
}

void io_repeatb(int argc, ydb_buffer_t *buf, ydb_int_t extra) {
	if (!argc) return;
	if (argc == 2) {
		assert(buf->len_used == 0);
		assert(buf->len_alloc == 0);
		assert(buf->buf_addr == NULL);
		printf("io_repeatb: no input argument passed\n");
		return;
	}
	assert(buf->len_alloc <= 100);
	assert(buf->buf_addr != NULL);
	printf("io_repeatb: buf_size=%d input_size=%d %.*s\n", buf->len_alloc, buf->len_used, buf->len_used, buf->buf_addr);
	memcpy(buf->buf_addr, s, 100);
	buf->len_used = 100;
}

void io_repeats(int argc, ydb_string_t *buf, ydb_int_t extra) {
	if (!argc) return;
	if (argc == 2) {
		assert(buf->length == 0);
		assert(buf->address == NULL);
		printf("io_repeats: no input argument passed\n");
		return;
	}
	assert(buf->address != NULL && "unreachable; if an argument is present it should have a buffer allocated");
	printf("io_repeats: input_size=%ld %.*s\n", buf->length, (int)buf->length, buf->address);
	memcpy(buf->address, s, 100);
	buf->length = 100;
}

void io_repeatc(int argc, ydb_char_t *buf, ydb_int_t extra) {
	if (!argc) return;
	assert(buf != NULL);
	if (argc == 2)
		assert(*buf == '\0');
	if (*buf == '\0')
		printf("io_repeatc: empty string or no input argument\n");
	printf("io_repeatc: input_size=%ld %s\n", strlen(buf), buf);
	// NOTE: we can copy one fewer byte because we need to reserve space for the null terminator.
	memcpy(buf, s, 99);
	buf[99] = '\0';
}
