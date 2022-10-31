/****************************************************************
 *								*
 * Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Helper C program used by r136/u_inref/ydb565.csh for the call-outs/external-call portion of the test */

#include <stdio.h>
#include <string.h>

#include "libyottadb.h"

void xc_preallocO(ydb_int_t count, ydb_buffer_t *o)
{
	return;
}

void xc_preallocIO(ydb_int_t count, ydb_buffer_t *io)
{
	return;
}

ydb_buffer_t *xc_test1(ydb_int_t count)
{
	return NULL;
}

void xc_test2(ydb_int_t count, ydb_buffer_t *o)
{
	o->buf_addr = NULL;
	o->len_used = 0;
	return;
}

void xc_test3(ydb_int_t count, ydb_buffer_t *io)
{
	io->buf_addr = NULL;
	io->len_used = 0;
	return;
}

void xc_test4(ydb_int_t count, ydb_buffer_t *o)
{
	o->buf_addr = "a";
	o->len_used = 0x100000 + 1;
	return;
}

void xc_test5(ydb_int_t count, ydb_buffer_t *io)
{
	io->buf_addr = "a";
	io->len_used = 0x100000 + 1;
	return;
}

ydb_buffer_t *xc_test6(void)
{
	ydb_buffer_t	*ret;

	ret = ydb_malloc(sizeof(ydb_buffer_t));
	ret->buf_addr = ydb_malloc(1);
	ret->len_used = 0x100000 + 1;
	return ret;
}

ydb_buffer_t *xc_test7(void)
{
	ydb_buffer_t	*ret;

	ret = ydb_malloc(sizeof(ydb_buffer_t));
	ret->buf_addr = NULL;
	ret->len_used = 1;
	return ret;
}

void xc_test8(ydb_int_t count, ydb_buffer_t *o)
{
	o->buf_addr = NULL;
	o->len_used = 1;
	return;
}

void xc_test9(ydb_int_t count, ydb_buffer_t *io)
{
	io->buf_addr = NULL;
	io->len_used = 1;
	return;
}

ydb_buffer_t *xc_test10(void)
{
	ydb_buffer_t	*ret;

	ret = ydb_malloc(sizeof(ydb_buffer_t));
	ret->buf_addr = ydb_malloc(1);
	ret->len_used = 0;
	return ret;
}

void xc_test11(ydb_int_t count, ydb_buffer_t *o)
{
	o->buf_addr = ydb_malloc(1);
	o->len_used = 0;
	return;
}

void xc_test12(ydb_int_t count, ydb_buffer_t *io)
{
	io->buf_addr = ydb_malloc(1);
	io->len_used = 0;
	return;
}

void xc_test13(ydb_int_t count, ydb_buffer_t *o)
{
	o->len_used = o->len_alloc + 1;	/* to trigger a EXCEEDSPREALLOC error */
	return;
}

ydb_buffer_t *xc_test14(ydb_int_t count, ydb_buffer_t *i, ydb_buffer_t *io, ydb_buffer_t *o)
{
	ydb_buffer_t	*ret;

	strcpy(o->buf_addr, "abcd");
	o->len_used = strlen("abcd");
	memcpy(io->buf_addr, "gh", 2);
	io->len_used = strlen("gh");
	ret = ydb_malloc(sizeof(ydb_buffer_t));
	ret->buf_addr = ydb_malloc(10);
	ret->len_alloc = ret->len_used = 10;
	memcpy(ret->buf_addr, "ab_gh_abcd", ret->len_used);
	return ret;
}

