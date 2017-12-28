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
#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */
#include <stdlib.h>
#include <string.h>
#include <errno.h>

/* The below mirrors YDBEOF/YDBSETS etc. in stresstest.m */
#define	YDBEOF		0
#define	YDBSETS		1
#define	YDBGETS		2
#define	YDBSUBSNEXT	3
#define	YDBSUBSPREV	4

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

void	lvnZWRITE(void);
void	gvnZWRITE(void);
int	fullread(char *buff, int len);

/* Read "len" bytes. If "read()" system call returns less than "len", keep retrying until we have "len" bytes */
int	fullread(char *buff, int len)
{
	int	toread = len, cnt;
	char	*ptr = buff;

	do
	{
		cnt = fread(ptr, 1, toread, stdin);
		assert(0 <= cnt);
		toread -= cnt;
		ptr += cnt;
	} while (toread);
	return len;
}

#define	DBG_BUFF_SIZE	65536
#define	READCNT_SIZE	256

typedef int (*ydb_retvalue_fnptr_t)(ydb_buffer_t *varname, int subs_used, ydb_buffer_t *subsarray, ydb_buffer_t *value);

int main()
{
	int		i, status, bufflen = 0, reclen, copylen, varnamelen, nsubs, valuelen, len, action, reccnt;
	ydb_buffer_t	basevar, subscr[32], value, retvalue;
	char		hdrbuff[8], *buff, *ptr, retvaluebuff[64];
	ssize_t		cnt;
	ydb_string_t	zwrarg;
	int		process_id = getpid();
	int		dbg_buff[DBG_BUFF_SIZE], dbg_buff_index = 0, readcnt[READCNT_SIZE], readcnt_buff_index[READCNT_SIZE], readcnt_index = 0;
	ydb_retvalue_fnptr_t	ydb_fn_array[] = {NULL, &ydb_set_s, &ydb_get_s, &ydb_subscript_next_s, &ydb_subscript_previous_s};

	for (reccnt = 0; ; reccnt++)
	{
		cnt = fullread(hdrbuff, 8);
		assert(8 == cnt);
		reclen = *(int *)hdrbuff;
		if (reclen > bufflen)
		{
			if (0 != bufflen)
				free(buff);
			bufflen = reclen * 2;
			buff = malloc(bufflen);
			assert(NULL != buff);
		}
		action = *(int *)(hdrbuff + 4);
		if (YDBEOF == action)
			break;
		assert((YDBSETS == action) || (YDBGETS == action) || (YDBSUBSNEXT == action) || (YDBSUBSPREV == action));
		cnt = fullread(buff, reclen);
		assert(cnt == reclen);
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
			assert(DBG_BUFF_SIZE > dbg_buff_index);
		}
		ptr = buff;
		varnamelen = *(int *)buff;
		ptr += 4;
		basevar.buf_addr = ptr;
		basevar.len_used = varnamelen;
		ptr += varnamelen;
		nsubs = *(int *)ptr;
		ptr += 4;
		assert(32 > nsubs);
		for (i = 0; i < nsubs; i++)
		{
			len = *(int *)ptr;
			ptr += 4;
			subscr[i].buf_addr = ptr;
			subscr[i].len_used = len;
			ptr += len;
		}
		valuelen = *(int *)ptr;
		ptr += 4;
		value.buf_addr = ptr;
		value.len_used = valuelen;
		ptr += valuelen;
		/* Now do the set. Since we don't know the # of subscripts, we code it for the max # = 32 */
		if (YDBSETS == action)
		{
			status = ydb_set_s(&basevar, nsubs, subscr, &value);
			assert(YDB_OK == status);
		} else if ((YDBGETS == action) || (YDBSUBSNEXT == action) || (YDBSUBSPREV == action))
		{
			retvalue.buf_addr = retvaluebuff;
			retvalue.len_alloc = sizeof(retvaluebuff);
			retvalue.len_used = 0;
			status = (*ydb_fn_array[action])(&basevar, nsubs, subscr, &retvalue);
			assert(YDB_OK == status);
			assert((retvalue.len_used == value.len_used)
				&& (!memcmp(retvalue.buf_addr, value.buf_addr, value.len_used)));
		}
	}
	/* List all lvns created by us */
	lvnZWRITE();
	/* List all glvns in database (== created by us since we are the only one accessing the db) */
	gvnZWRITE();
	return YDB_OK;
}
