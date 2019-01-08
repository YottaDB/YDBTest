/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.*
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
#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */
#include <stdlib.h>
#include <string.h>
#include <errno.h>

/* The below mirrors YDBEOF/YDBSETS etc. in stresstest.m */
#define	YDBEOF		0
#define	YDBSET		1
#define	YDBGET		2
#define	YDBKILL		3
#define	YDBZKILL	4

void	lvnZWRITE(uint64_t tptoken);
void	gvnZWRITE(uint64_t tptoken);
int	fullread(char *buff, int len);

/* Read "len" bytes. If "read()" system call returns less than "len", keep retrying until we have "len" bytes */
int	fullread(char *buff, int len)
{
	int	toread = len, cnt;
	char	*ptr = buff;

	do
	{
		cnt = fread(ptr, 1, toread, stdin);
		YDB_ASSERT(0 <= cnt);
		toread -= cnt;
		ptr += cnt;
	} while (toread);
	return len;
}

#define	DBG_BUFF_SIZE	65536
#define	READCNT_SIZE	256

int main(int argc, char *argv[])
{
	int		i, status, bufflen = 0, reclen, copylen, varnamelen, nsubs, valuelen, len, action, reccnt;
	ydb_buffer_t	basevar, subscr[32], value, retvalue;
	char		hdrbuff[8], *buff, *ptr, retvaluebuff[64];
	ssize_t		cnt;
	ydb_string_t	zwrarg;
	int		process_id = getpid();
	int		dbg_buff[DBG_BUFF_SIZE], dbg_buff_index = 0, readcnt[READCNT_SIZE], readcnt_buff_index[READCNT_SIZE], readcnt_index = 0;

	if (argc != 1)
	{	/* This is for debug purposes. To rerun as say "./stresstest 1 < /dev/zero" and that will invoke genstresstest.m
		 * and do exactly the same set of updates (through a call-in) that the test did and then invoke zwrite of
		 * local nodes and global nodes using SimpleThreadAPI.
		 */
		status = ydb_ci_t(YDB_NOTTP, NULL, "genstresstest");
		YDB_ASSERT(0 == status);
	}
	for (reccnt = 0; ; reccnt++)
	{
		cnt = fullread(hdrbuff, 8);
		YDB_ASSERT(8 == cnt);
		reclen = *(int *)hdrbuff;
		if (reclen > bufflen)
		{
			if (0 != bufflen)
				free(buff);
			bufflen = reclen * 2;
			buff = malloc(bufflen);
			YDB_ASSERT(NULL != buff);
		}
		action = *(int *)(hdrbuff + 4);
		if (YDBEOF == action)
			break;
		YDB_ASSERT((YDBSET == action) || (YDBGET == action) || (YDBKILL == action) || (YDBZKILL == action));
		cnt = fullread(buff, reclen);
		YDB_ASSERT(cnt == reclen);
		readcnt[readcnt_index] = cnt;
		readcnt_buff_index[readcnt_index] = dbg_buff_index;
		readcnt_index++;
		if (READCNT_SIZE == readcnt_index)
			readcnt_index = 0;
		if ((dbg_buff_index + reclen) <= DBG_BUFF_SIZE)
			copylen = reclen;
		else
			copylen = DBG_BUFF_SIZE - dbg_buff_index;
		memcpy(&dbg_buff[dbg_buff_index], buff, copylen);
		dbg_buff_index += copylen;
		if (DBG_BUFF_SIZE <= dbg_buff_index)
			dbg_buff_index -= DBG_BUFF_SIZE;
		if (copylen < reclen)
		{
			copylen = reclen - copylen;
			memcpy(&dbg_buff[dbg_buff_index], buff, copylen);
			dbg_buff_index += copylen;
			YDB_ASSERT(DBG_BUFF_SIZE > dbg_buff_index);
		}
		ptr = buff;
		varnamelen = *(int *)buff;
		ptr += 4;
		basevar.buf_addr = ptr;
		basevar.len_used = basevar.len_alloc = varnamelen;
		ptr += varnamelen;
		nsubs = *(int *)ptr;
		ptr += 4;
		YDB_ASSERT(32 > nsubs);
		for (i = 0; i < nsubs; i++)
		{
			len = *(int *)ptr;
			ptr += 4;
			subscr[i].buf_addr = ptr;
			subscr[i].len_used = len;
			subscr[i].len_alloc = len;
			ptr += len;
		}
		valuelen = *(int *)ptr;
		ptr += 4;
		value.buf_addr = ptr;
		value.len_used = valuelen;
		value.len_alloc = valuelen;
		ptr += valuelen;
		/* Now do the set. Since we don't know the # of subscripts, we code it for the max # = 32 */
		if (YDBSET == action)
		{
			status = ydb_set_st(YDB_NOTTP, NULL, &basevar, nsubs, subscr, &value);
			YDB_ASSERT(YDB_OK == status);
		} else if (YDBKILL == action)
		{
			status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, nsubs, subscr, YDB_DEL_TREE);
			YDB_ASSERT(YDB_OK == status);
		} else if (YDBZKILL == action)
		{
			status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, nsubs, subscr, YDB_DEL_NODE);
			YDB_ASSERT(YDB_OK == status);
		} else if (YDBGET == action)
		{
			retvalue.buf_addr = retvaluebuff;
			retvalue.len_alloc = sizeof(retvaluebuff);
			retvalue.len_used = 0;
			status = ydb_get_st(YDB_NOTTP, NULL, &basevar, nsubs, subscr, &retvalue);
			YDB_ASSERT(YDB_OK == status);
			YDB_ASSERT((retvalue.len_used == value.len_used)
				   && (!memcmp(retvalue.buf_addr, value.buf_addr, value.len_used)));
		}
	}
	/* List all lvns created by us */
	lvnZWRITE(YDB_NOTTP);
	/* List all glvns in database (== created by us since we are the only one accessing the db) */
	gvnZWRITE(YDB_NOTTP);
	return YDB_OK;
}
