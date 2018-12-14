/****************************************************************
 *                                                              *
 * Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.     *
 * All rights reserved.                                         *
 *                                                              *
 *      This source code contains the intellectual property     *
 *      of its copyright holder(s), and is made available       *
 *      under a license.  If you do not know the terms of       *
 *      the license, please stop and do not read further.       *
 *                                                              *
 ****************************************************************/

#include <libyottadb.h>
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include <unistd.h>

#define DEF_VAR "^Ar"
#define AREG_VAR "^A"
#define VALUE1 "Ready"
#define COUNT_IND "^An"
char string[64];
int status, copy_done;
ydb_buffer_t def, areg, value1, count, return_test, return_count, ydb_log;
char	errbuf[1024], retvaluebuff[64], countvaluebuff[64], ydblogbuf[128];

void printLog(char *log, ydb_buffer_t return_count, ydb_buffer_t count)
{
	ydb_incr_s(&count,0,NULL,NULL,&return_count);
	return_count.buf_addr[return_count.len_used]='\0';

	YDB_COPY_STRING_TO_BUFFER(log, &ydb_log, copy_done);
	YDB_ASSERT(copy_done);
	ydb_log.buf_addr[ydb_log.len_used]='\0';

	status = ydb_set_s(&areg,1,&return_count,&ydb_log);
	YDB_ASSERT(YDB_OK == status);
}

void YDB_STRING_INIT(ydb_buffer_t *ydb_buffer, char *buffer, int alloc)
{
	ydb_buffer->buf_addr = &buffer[0];
	ydb_buffer->len_used = 0;
	ydb_buffer->len_alloc = alloc;
}

int callout()
{
	YDB_LITERAL_TO_BUFFER(DEF_VAR, &def);
	YDB_LITERAL_TO_BUFFER(AREG_VAR, &areg);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);
	YDB_LITERAL_TO_BUFFER(COUNT_IND, &count);

	ydb_init();
	YDB_STRING_INIT(&return_test, retvaluebuff, 64);
	YDB_STRING_INIT(&return_count, countvaluebuff, 64);
	YDB_STRING_INIT(&ydb_log, ydblogbuf, 128);
	return_test.len_used = 0;
	return_count.len_used = 0;
	ydb_log.len_used = 0;
	status = ydb_get_s(&areg,0,NULL,&return_test);
	if (0 != status)
	{
		ydb_zstatus(errbuf, 1024);
		printf("ydb_get_s: %s\n", errbuf); fflush(stdout);
		return status;
	}
	return_test.buf_addr[return_test.len_used] = '\0';
	printLog("1: In gtm8926.c", return_count, count);
	status = ydb_set_s(&def,0,NULL,&value1);
	sprintf(string, "1: %s set to %s", DEF_VAR, VALUE1);
	printLog(string, return_count, count);

	/* Sleep time is set to 2 since the time to write to disk (Flush dirty buffer) is 1 second,
	   we want to wait in the C call at least twice this duration.				   */
	printLog("1: Sleeping in intervals of 2 seconds waiting for confirmation that a flush has not occurred", return_count, count);
	printLog("1: Sleep time is 2 since the time to flush is 1 second", return_count, count);
	sleep(2);
	if (0 != status)
	{
		ydb_zstatus(errbuf, 1024);
		printf("ydb_set_s: %s\n", errbuf);
		return status;
	}

	while(1)
	{
		status = ydb_get_s(&areg,0,NULL,&return_test);
		if (0 != status)
		{
			ydb_zstatus(errbuf, 1024);
			printf("ydb_get_s: %s", errbuf);
			return status;
		}
		return_test.buf_addr[return_test.len_used] = '\0';
		if(strcmp("True", return_test.buf_addr) == 0)
		{
			sprintf(string, "1: ^A found to be %s", return_test.buf_addr);
			printLog(string, return_count, count);
			printLog("1: External call succesfully delayed database flush", return_count, count);
			return 0;
			break;
		} else if(strcmp("False", return_test.buf_addr) == 0)
		{
			sprintf(string, "1: ^A found to be %s", return_test.buf_addr);
			printLog(string, return_count, count);
			printLog("1: External call did not delay database flush", return_count, count);
			return 0;
			break;
		}
		sleep(2);
	}
}
