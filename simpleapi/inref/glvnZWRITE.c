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
void	glvnZWRITEsubtree(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr);
void	glvnPrintNodeIfExists(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr);

/* Lists ALL local variable nodes in a process in ZWRITE order */
void	lvnZWRITE(void)
{
	ydb_buffer_t	retvalue, basevar;
	int		status;
	char		retvaluebuff[BUFFALLOCLEN], basevarbuff[BUFFALLOCLEN];
	ydb_buffer_t	subscr[YDB_MAX_SUBS + 1];

	retvalue.buf_addr = retvaluebuff;
	retvalue.len_alloc = sizeof(retvaluebuff);
	retvalue.len_used = 0;
	basevar.buf_addr = basevarbuff;
	basevar.len_alloc = sizeof(basevarbuff);
	basevar.buf_addr[0] = '%';
	basevar.len_used = 1;
	/* First go through all local variable names in symbol table */
	for ( ; ; )
	{
		status = ydb_subscript_next_s(&basevar, 0, NULL, &retvalue);
		assert(YDB_OK == status);
		if (!retvalue.len_used)
			break;
		assert(basevar.len_alloc >= retvalue.len_used);
		memcpy(basevar.buf_addr, retvalue.buf_addr, retvalue.len_used);
		basevar.len_used = retvalue.len_used;
		glvnZWRITEsubtree(&basevar, 0, &subscr[0]);
	}
	return;
}

/* Lists ALL global variable nodes in the database in ZWRITE order */
void	gvnZWRITE(void)
{
	ydb_buffer_t	retvalue, basevar;
	int		status;
	char		retvaluebuff[BUFFALLOCLEN], basevarbuff[BUFFALLOCLEN];
	ydb_buffer_t	subscr[YDB_MAX_SUBS + 1];

	retvalue.buf_addr = retvaluebuff;
	retvalue.len_alloc = sizeof(retvaluebuff);
	retvalue.len_used = 0;
	basevar.buf_addr = basevarbuff;
	basevar.len_alloc = sizeof(basevarbuff);
	basevar.buf_addr[0] = '^';
	basevar.buf_addr[1] = '%';
	basevar.len_used = 2;
	/* First go through all local variable names in symbol table */
	for ( ; ; )
	{
		status = ydb_subscript_next_s(&basevar, 0, NULL, &retvalue);
		assert(YDB_OK == status);
		if (!retvalue.len_used)
			break;
		assert(basevar.len_alloc >= retvalue.len_used);
		memcpy(basevar.buf_addr, retvalue.buf_addr, retvalue.len_used);
		basevar.len_used = retvalue.len_used;
		glvnZWRITEsubtree(&basevar, 0, &subscr[0]);
	}
	return;
}

void glvnZWRITEsubtree(ydb_buffer_t *basevar, int nsubs, ydb_buffer_t *subscr)
{
	ydb_buffer_t	*cursubs;
	char		subsbuff[BUFFALLOCLEN];
	int		status;
	unsigned int	ret_dlrdata;
	ydb_buffer_t	retvalue;
	char		retvaluebuff[BUFFALLOCLEN];

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
	for ( ; ; )
	{
		status = ydb_subscript_next_s(basevar, nsubs + 1, subscr, &retvalue);
		assert(YDB_OK == status);
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

