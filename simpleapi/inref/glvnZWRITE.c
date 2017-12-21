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
#include "libydberrors.h"

#include <stdio.h>
#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */
#include <stdlib.h>
#include <string.h>
#include <errno.h>

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

#define	BUFFALLOCLEN	64

void	lvnZWRITE(void);
void	gvnZWRITE(void);
void	glvnZWRITE(char *startname);
void	glvnZWRITEsubtree(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr);
void	glvnPrintNodeIfExists(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr);

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
	char		basevarbuff[BUFFALLOCLEN];
	ydb_buffer_t	retvalue, tmpvalue;
	int		status, startnamelen, iters;
	char		retvaluebuff[BUFFALLOCLEN], tmpvaluebuff[BUFFALLOCLEN];
	ydb_buffer_t	subscr[YDB_MAX_SUBS + 1];

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
	for (iters=0; ; iters++)
	{
		status = ydb_subscript_next_s(&basevar, 0, NULL, &retvalue);
		assert(YDB_OK == status);
		/* NARSTODO: If retvalue.len_used is 0, need to do reverse $order of "zzzzzzzzzzzzzz...". */
		if (retvalue.len_used)
		{
			status = ydb_subscript_previous_s(&retvalue, 0, NULL, &tmpvalue);
			assert(YDB_OK == status);
			assert((tmpvalue.len_used == basevar.len_used)
				|| (!tmpvalue.len_used && !iters)
				|| !tmpvalue.len_used
				|| (!memcmp(tmpvalue.buf_addr, basevar.buf_addr, basevar.len_used)));
		}
		if (!retvalue.len_used)
			break;
		assert(basevar.len_alloc >= retvalue.len_used);
		memcpy(basevar.buf_addr, retvalue.buf_addr, retvalue.len_used);
		basevar.len_used = retvalue.len_used;
		glvnZWRITEsubtree(&basevar, 0, &subscr[0]);
	}
}

void glvnZWRITEsubtree(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr)
{
	ydb_buffer_t	*cursubs, tmpvalue, tmpvalue2;
	char		subsbuff[BUFFALLOCLEN];
	int		status;
	unsigned int	ret_dlrdata;
	ydb_buffer_t	retvalue;
	char		retvaluebuff[BUFFALLOCLEN], tmpvaluebuff[BUFFALLOCLEN];

	glvnPrintNodeIfExists(basevar, nsubs, subscr);
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
	tmpvalue.buf_addr = tmpvaluebuff;
	tmpvalue.len_alloc = sizeof(tmpvaluebuff);
	tmpvalue.len_used = 0;
	for ( ; ; )
	{
		status = ydb_subscript_next_s(basevar, nsubs + 1, subscr, &retvalue);
		assert(YDB_OK == status);
		tmpvalue2 = subscr[nsubs];
		subscr[nsubs] = retvalue;
		status = ydb_subscript_previous_s(basevar, nsubs + 1, subscr, &tmpvalue);
		assert(YDB_OK == status);
		assert(tmpvalue.len_used == tmpvalue2.len_used);
		assert(!tmpvalue.len_used || (!memcmp(tmpvalue.buf_addr, tmpvalue2.buf_addr, tmpvalue2.len_used)));
		subscr[nsubs] = tmpvalue2;
		if (!retvalue.len_used)
			break;
		memcpy(cursubs->buf_addr, retvalue.buf_addr, retvalue.len_used);
		cursubs->len_used = retvalue.len_used;
		glvnZWRITEsubtree(basevar, nsubs + 1, subscr);
	}
	return;
}

void	glvnPrintNodeIfExists(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr)
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
		return;
	assert(YDB_OK == status);
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
			assert(YDB_OK == status);
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
	assert(YDB_OK == status);
	memcpy(ptr, zwr.buf_addr, zwr.len_used);
	ptr += zwr.len_used;
	*ptr++ = '\0';
	printf("%s\n", strbuff);
	return;
}

