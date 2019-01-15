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
#include <time.h>
#include <sys/types.h>

#define	LOCK_TIMEOUT	1000000
#define ERRBUF_SIZE	1024


int main()
{
	int		i, status, errnum;
	ydb_buffer_t	err_return, err_return2;
	char		errbuf[ERRBUF_SIZE], err_returnbuf[64], err_return2buf[64];

	err_return.buf_addr = err_returnbuf;
	err_return.len_alloc = sizeof(err_returnbuf);
	err_return.len_used = 0;


	printf("### Test Functionality of ydb_message() in the SimpleAPI ###\n"); fflush(stdout);

	printf("\n# Test ydb_message() with the errnum for YDB_ERR_PARAMINVALID: %d\n", YDB_ERR_PARAMINVALID); fflush(stdout);

	errnum = YDB_ERR_PARAMINVALID;
	status = ydb_message(errnum, &err_return);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	err_return.buf_addr[err_return.len_used] = '\0';
	printf("ydb_message() returns \n%s\n", err_return.buf_addr); fflush(stdout);

	printf("\n### Test Error scenarios of ydb_message() in the SimpleAPI ###\n"); fflush(stdout);

	err_return2.buf_addr = err_return2buf;
	err_return2.len_alloc = sizeof(err_return2buf);
	err_return2.len_used = 0;

	printf("# Test of YDB_ERR_UNKNOWNSYSERR error\n"); fflush(stdout);
	status = ydb_message(YDB_INT_MAX, &err_return2);
	if (YDB_OK != status)
	{
		if (err_return2.len_used != 0)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("Line[%d]: %s\n", __LINE__, errbuf);
			printf("error, len_used not 0\n");
			fflush(stdout);
		} else
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("Line[%d]: %s\n", __LINE__, errbuf);
			printf("msg_buff remains unchanged\n");
			fflush(stdout);
		}
	} else
	{
		err_return2.buf_addr[err_return2.len_used] = '\0';
		printf("error returned: \n%s\n", err_return2.buf_addr);
		fflush(stdout);
	}

	printf("\n# Test of YDB_ERR_INVSTRLEN error\n"); fflush(stdout);

	err_return2.len_alloc = 5;
	status = ydb_message(YDB_ERR_PARAMINVALID, &err_return2);
	if (YDB_OK != status)
	{
		if (err_return2.len_used > err_return2.len_alloc)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("Line[%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		} else
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("ERROR Line[%d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		}
	}
	err_return2.len_alloc = sizeof(err_return2buf);

	printf("\n# Test of YDB_ERR_PARAMINVALID error\n"); fflush(stdout);

	printf("# Test with msg_buff->buf_addr = NULL\n"); fflush(stdout);
	err_return2.buf_addr = NULL;
	status = ydb_message(YDB_ERR_PARAMINVALID, &err_return2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Test with msg_buff = NULL\n"); fflush(stdout);
	status = ydb_message(YDB_ERR_PARAMINVALID, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	return YDB_OK;

}
