/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries. *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "libyottadb.h"

#include <sys/types.h>	/* needed for "getpid" */
#include <unistd.h>	/* needed for "getpid" */
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <time.h>	/* needed for "time" */
#include <stdlib.h>	/* needed for "drand48" and others */

#define	BUFFALLOCLEN	64
#define	LASTLVNAME	"zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
#define	LASTGVNAME	"^zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

#define	FALSE	0
#define	TRUE	1

#define	NODE_MUST_EXIST_FALSE	FALSE
#define	NODE_MUST_EXIST_TRUE	TRUE

static int	rand_value;

void	lvnZWRITE(void);
void	gvnZWRITE(void);
void	glvnZWRITE(char *startname);
void	glvnZWRITEsubtree(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr);
void	glvnPrintNodeIfExists(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr, int node_must_exist);

/* Lists ALL local variable nodes in a process in ZWRITE order */
void	lvnZWRITE(void)
{
	return glvnZWRITE("%"); /* Go through all local variable nodes */
}

/* Lists ALL global variable nodes in the database in ZWRITE order */
void	gvnZWRITE(void)
{
	return glvnZWRITE("^%"); /* Go through all global variable nodes */
}

void glvnZWRITE(char *startname)
{
	ydb_buffer_t	basevar;
	char		basevarbuff[BUFFALLOCLEN], *name;
	ydb_buffer_t	retvalue, tmpvalue;
	int		seed, status, startnamelen, iters, reached_end;
	char		retvaluebuff[BUFFALLOCLEN], tmpvaluebuff[BUFFALLOCLEN];
	ydb_buffer_t	subscr[YDB_MAX_SUBS + 1];
	unsigned int	ret_dlrdata;
	static int	rand_chosen = FALSE;

	if (!rand_chosen)
	{
		seed = (time(NULL) * getpid());
		srand48(seed);
		/* Randomly choose ydb_subscript_next_s() or ydb_node_next_s() to traverse the Global/Local Variable Tree */
		rand_value = (2 * drand48());
	}
	basevar.buf_addr = basevarbuff;
	basevar.len_alloc = sizeof(basevarbuff);
	startnamelen = strlen(startname);
	basevar.len_used = startnamelen;
	memcpy(basevar.buf_addr, startname, basevar.len_used);
	tmpvalue.buf_addr = tmpvaluebuff;
	tmpvalue.len_alloc = sizeof(tmpvaluebuff);
	tmpvalue.len_used = 0;
	retvalue.buf_addr = retvaluebuff;
	retvalue.len_alloc = sizeof(retvaluebuff);
	retvalue.len_used = 0;
	status = ydb_data_s(&basevar, 0, subscr, &ret_dlrdata);
	if (ret_dlrdata)
		glvnZWRITEsubtree(&basevar, 0, subscr);
	for (iters=0; ; iters++)
	{
		status = ydb_subscript_next_s(&basevar, 0, NULL, &retvalue);
		YDB_ASSERT((YDB_OK == status) || (YDB_ERR_NODEEND == status));
		reached_end = (YDB_ERR_NODEEND == status);
		if (reached_end)
		{	/* Reached end of subscripts. In order to find last subscript do reverse $order of "zzzzzzzzzzzzzz...". */
			if ('^' == basevar.buf_addr[0])
				name = LASTGVNAME;
			else
				name = LASTLVNAME;
			retvalue.len_used = strlen(name);
			memcpy(retvalue.buf_addr, name, retvalue.len_used);
		}
		status = ydb_subscript_previous_s(&retvalue, 0, NULL, &tmpvalue);
		YDB_ASSERT((YDB_OK == status) || (YDB_ERR_NODEEND == status));
		YDB_ASSERT((tmpvalue.len_used == basevar.len_used)
			|| (!tmpvalue.len_used && !iters)
			|| !tmpvalue.len_used
			|| (!memcmp(tmpvalue.buf_addr, basevar.buf_addr, basevar.len_used)));
		if (reached_end)
			break;
		YDB_ASSERT(basevar.len_alloc >= retvalue.len_used);
		memcpy(basevar.buf_addr, retvalue.buf_addr, retvalue.len_used);
		basevar.len_used = retvalue.len_used;
		glvnZWRITEsubtree(&basevar, 0, &subscr[0]);
	}
}

void glvnZWRITEsubtree(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr)
{
	int		status;

	if (!rand_value)
	{	/* Use ydb_subscript_next_s to traverse the Global/Local Variable Tree */
		ydb_buffer_t	*cursubs, tmpvalue, tmpvalue2;
		char		subsbuff[BUFFALLOCLEN];
		unsigned int	ret_dlrdata;
		ydb_buffer_t	retvalue;
		char		retvaluebuff[BUFFALLOCLEN], tmpvaluebuff[BUFFALLOCLEN];

		glvnPrintNodeIfExists(basevar, nsubs, subscr, NODE_MUST_EXIST_FALSE);
		if (YDB_MAX_SUBS == nsubs)	/* cannot have a subtree if we are already at MAXNRSUBSCRIPTS level */
			return;
		retvalue.buf_addr = retvaluebuff;
		retvalue.len_alloc = sizeof(retvaluebuff);
		retvalue.len_used = 0;
		cursubs = &subscr[nsubs];
		cursubs->buf_addr = subsbuff;
		cursubs->len_alloc = sizeof(subsbuff);
		cursubs->len_used = 0;
		status = ydb_data_s(basevar, nsubs + 1, subscr, &ret_dlrdata);
		if (ret_dlrdata)
			glvnZWRITEsubtree(basevar, nsubs + 1, subscr);
		cursubs->len_used = 0;
		tmpvalue.buf_addr = tmpvaluebuff;
		tmpvalue.len_alloc = sizeof(tmpvaluebuff);
		tmpvalue.len_used = 0;
		for ( ; ; )
		{
			status = ydb_subscript_next_s(basevar, nsubs + 1, subscr, &retvalue);
			YDB_ASSERT((YDB_OK == status) || (YDB_ERR_NODEEND == status));
			if (YDB_ERR_NODEEND == status)
				retvalue.len_used = 0;
			tmpvalue2 = subscr[nsubs];
			subscr[nsubs] = retvalue;
			status = ydb_subscript_previous_s(basevar, nsubs + 1, subscr, &tmpvalue);
			YDB_ASSERT((YDB_OK == status) || (YDB_ERR_NODEEND == status));
			if (YDB_ERR_NODEEND == status)
				tmpvalue.len_used = 0;
			YDB_ASSERT(tmpvalue.len_used == tmpvalue2.len_used);
			YDB_ASSERT(!tmpvalue.len_used || (!memcmp(tmpvalue.buf_addr, tmpvalue2.buf_addr, tmpvalue2.len_used)));
			subscr[nsubs] = tmpvalue2;
			if (!retvalue.len_used)
				break;
			memcpy(cursubs->buf_addr, retvalue.buf_addr, retvalue.len_used);
			cursubs->len_used = retvalue.len_used;
			glvnZWRITEsubtree(basevar, nsubs + 1, subscr);
		}
	} else
	{	/* Use ydb_node_next_s to traverse the Global/Local Variable Tree */
		/* NARSTODO: Test ydb_node_previous_s too */

		ydb_buffer_t	src_subscr[YDB_MAX_SUBS + 1], dst_subscr[YDB_MAX_SUBS + 1], *src, *dst, *tmp;
		char		src_subscr_buff[YDB_MAX_SUBS + 1][BUFFALLOCLEN];
		char		dst_subscr_buff[YDB_MAX_SUBS + 1][BUFFALLOCLEN];
		int		i, src_used, dst_used, node_must_exist;

		YDB_ASSERT(0 == nsubs);
		for (i = 0; i < YDB_MAX_SUBS + 1; i++)
		{
			src = &src_subscr[i];
			src->buf_addr = src_subscr_buff[i];
			src->len_alloc = sizeof(src_subscr_buff[i]);
			src->len_used = 0;
			dst = &dst_subscr[i];
			dst->buf_addr = dst_subscr_buff[i];
			dst->len_alloc = sizeof(dst_subscr_buff[i]);
			dst->len_used = 0;
		}
		src_used = 0;
		src = src_subscr;
		dst = dst_subscr;
		dst_used = YDB_MAX_SUBS + 1;
		node_must_exist = NODE_MUST_EXIST_FALSE;
		do
		{
			glvnPrintNodeIfExists(basevar, src_used, src, node_must_exist);
			status = ydb_node_next_s(basevar, src_used, src, &dst_used, dst);
			if (YDB_ERR_NODEEND == status)
				break;
			YDB_ASSERT(YDB_OK == status);
			node_must_exist = NODE_MUST_EXIST_TRUE;
			src_used = dst_used;
			dst_used = YDB_MAX_SUBS + 1;
			tmp = src;
			src = dst;
			dst = tmp;
		} while (1);
	}
	return;
}

void	glvnPrintNodeIfExists(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr, int node_must_exist)
{
	int		i, len;
	char		strbuff[1024], zwrbuff[1024], *ptr;
	ydb_buffer_t	zwr;
	int		status;
	ydb_buffer_t	retvalue;
	char		retvaluebuff[BUFFALLOCLEN];

	retvalue.buf_addr = retvaluebuff;
	retvalue.len_alloc = sizeof(retvaluebuff);
	retvalue.len_used = 0;
	status = ydb_get_s(basevar, nsubs, subscr, &retvalue);
	if ((('^' != basevar->buf_addr[0]) && (YDB_ERR_LVUNDEF == status))
			|| (('^' == basevar->buf_addr[0]) && (YDB_ERR_GVUNDEF == status)))
	{
		YDB_ASSERT(NODE_MUST_EXIST_FALSE == node_must_exist);
		return;
	}
	YDB_ASSERT(YDB_OK == status);
	ptr = &strbuff[0];
	len = basevar->len_used;
	memcpy(ptr, basevar->buf_addr, len);
	ptr += len;
	zwr.buf_addr = zwrbuff;
	zwr.len_alloc = sizeof(zwrbuff);
	zwr.len_used = 0;
	if (nsubs)
	{
		*ptr++ = '(';
		for (i = 0; ; )
		{
			status = ydb_str2zwr_s(&subscr[i], &zwr);
			YDB_ASSERT(YDB_OK == status);
			memcpy(ptr, zwr.buf_addr, zwr.len_used);
			ptr += zwr.len_used;
			i++;
			if (i < nsubs)
				*ptr++ = ',';
			else
				break;
		}
		*ptr++ = ')';
	}
	*ptr++ = '=';
	status = ydb_str2zwr_s(&retvalue, &zwr);
	YDB_ASSERT(YDB_OK == status);
	memcpy(ptr, zwr.buf_addr, zwr.len_used);
	ptr += zwr.len_used;
	*ptr++ = '\0';
	printf("%s\n", strbuff);
	return;
}
