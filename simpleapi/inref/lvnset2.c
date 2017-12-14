/****************************************************************
 *								*
 * Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	*
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
#define	MAX_SUBS	32

#define BASEVAR "baselv"
#define SUBSCR1	"42"
#define SUBSCR2 "answer:"
#define VALUE1	"A question"
#define VALUE2	"One less than 43"
#define VALUE3 	"Life, the universe, and everything"

/* Test 32-level (max-deep) subscripts can be set in Local Variables */
int main()
{
	int		status, subs;
	ydb_buffer_t	basevar, subscr1, subscr2, value1, value2, value3, subsbuff[MAX_SUBS + 1];
	char		errbuf[ERRBUF_SIZE], subsstrlit[MAX_SUBS][3];	/* 3 to hold 2 digit decimal # + trailing null char */
	ydb_string_t	zwrarg;

	/* Initialize varname, subscript, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&subscr1, SUBSCR1);
	YDB_STRLIT_TO_BUFFER(&subscr2, SUBSCR2);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);
	YDB_STRLIT_TO_BUFFER(&value2, VALUE2);
	YDB_STRLIT_TO_BUFFER(&value3, VALUE3);
	/* Set a base variable, no subscripts */
	status = ydb_set_s(&value1, 0, &basevar);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set single subscript value */
	status = ydb_set_s(&value2, 1, &basevar, &subscr1);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set two subscript value */
	status = ydb_set_s(&value3, 2, &basevar, &subscr1, &subscr2);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() [3]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Set 32-level deep subscripts */
	for (subs = 0; subs <= MAX_SUBS; subs++)
	{
		subsbuff[subs].len_used = sprintf(subsstrlit[subs], "%d", subs);
		subsbuff[subs].buf_addr = subsstrlit[subs];
	}
	status = ydb_set_s(&subsbuff[1], 0, &basevar, &subsbuff[0]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [0]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[2], 1, &basevar, &subsbuff[0], &subsbuff[1]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [1]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[3], 2, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [2]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[4], 3, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [3]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[5], 4, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [4]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[6], 5, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [5]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[7], 6, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [6]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[8], 7, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [7]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[9], 8, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [8]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[10], 9, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [9]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[11], 10, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [10]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[12], 11, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [11]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[13], 12, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [12]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[14], 13, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [13]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[15], 14, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [14]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[16], 15, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [15]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[17], 16, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [16]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[18], 17, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [17]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[19], 18, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [18]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[20], 19, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [19]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[21], 20, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [20]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[22], 21, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [21]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[23], 22, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [22]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[24], 23, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [23]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[25], 24, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23], &subsbuff[24]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [24]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[26], 25, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23], &subsbuff[24], &subsbuff[25]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [25]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[27], 26, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23], &subsbuff[24], &subsbuff[25], &subsbuff[26]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [26]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[28], 27, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23], &subsbuff[24], &subsbuff[25], &subsbuff[26], &subsbuff[27]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [27]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[29], 28, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23], &subsbuff[24], &subsbuff[25], &subsbuff[26], &subsbuff[27], &subsbuff[28]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [28]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[30], 29, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23], &subsbuff[24], &subsbuff[25], &subsbuff[26], &subsbuff[27], &subsbuff[28], &subsbuff[29]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [29]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[31], 30, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23], &subsbuff[24], &subsbuff[25], &subsbuff[26], &subsbuff[27], &subsbuff[28], &subsbuff[29], &subsbuff[30]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [30]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_set_s(&subsbuff[32], 31, &basevar, &subsbuff[0], &subsbuff[1], &subsbuff[2], &subsbuff[3], &subsbuff[4], &subsbuff[5], &subsbuff[6], &subsbuff[7], &subsbuff[8], &subsbuff[9], &subsbuff[10], &subsbuff[11], &subsbuff[12], &subsbuff[13], &subsbuff[14], &subsbuff[15], &subsbuff[16], &subsbuff[17], &subsbuff[18], &subsbuff[19], &subsbuff[20], &subsbuff[21], &subsbuff[22], &subsbuff[23], &subsbuff[24], &subsbuff[25], &subsbuff[26], &subsbuff[27], &subsbuff[28], &subsbuff[29], &subsbuff[30], &subsbuff[31]);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_set_s() : subsbuff [31]: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	/* Demonstrate our progress by executing a ZWRITE in a call-in */
	zwrarg.address = NULL;
	zwrarg.length = 0;
	status = ydb_ci("driveZWRITE", &zwrarg);
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("driveZWRITE error: %s\n", errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	return YDB_OK;
}
