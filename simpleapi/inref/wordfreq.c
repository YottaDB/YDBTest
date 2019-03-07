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

#include "libyottadb.h"	/* for ydb_* macros/prototypes/typedefs */

#include <sys/types.h>	/* needed for "getpid" */
#include <unistd.h>	/* needed for "getpid" */
#include <stdio.h>	/* for "printf" */
#include <string.h>	/* for "strtok" */
#include <ctype.h>	/* for "toupper" */

/* count and report word frequencies for http://www.cs.duke.edu/csed/code/code2007/ */
int main()
{
	ydb_buffer_t	tmp1, tmp2, index, words, words_tmp1, null;
	ydb_buffer_t	index_subscr[2], value;
	char		tmp1buff[64], tmp2buff[64], valuebuff[64], words_tmp1buff[64], linebuff[1024], *lineptr, *ptr, *tmp_ptr;
	int		status;

	/* Initialize all array variable names we are planning to use. Randomly use locals vs globals to store word frequencies. */
	/* If using globals, delete any previous contents */
	if (getpid() % 2)
	{
		YDB_LITERAL_TO_BUFFER("words", &words);
		YDB_LITERAL_TO_BUFFER("index", &index);
	} else
	{
		YDB_LITERAL_TO_BUFFER("^words", &words);
		ydb_delete_s(&words, 0, NULL, YDB_DEL_TREE);
		YDB_LITERAL_TO_BUFFER("^index", &index);
		ydb_delete_s(&index, 0, NULL, YDB_DEL_TREE);
	}
	value.buf_addr = &valuebuff[0];
	value.len_used = 0;
	value.len_alloc = sizeof(valuebuff);
	do
	{
		lineptr = fgets(linebuff, sizeof(linebuff), stdin);
		if (NULL == lineptr)
			break;
		ptr = strtok(lineptr, " ");
		while (NULL != ptr)
		{	/* convert word pointed to by "ptr" to lowercase */
			tmp_ptr = ptr;
			while (*tmp_ptr)
			{
				*tmp_ptr = tolower(*tmp_ptr);
				tmp_ptr++;
			}
			/* */
			tmp1.buf_addr = ptr;
			tmp1.len_used = tmp_ptr - ptr;
			if (tmp_ptr[-1] == '\n')
				tmp1.len_used--;	/* - 1 to remove trailing newline */
			if (tmp1.len_used)
			{
				tmp1.len_alloc = tmp1.len_used;
				status = ydb_incr_s(&words, 1, &tmp1, NULL, &value);	/* M line : set value=$incr(words(tmp1)) */
				YDB_ASSERT(YDB_OK == status);
			}
			ptr = strtok(NULL, " ");
		}
	} while (1);
	tmp1.buf_addr = tmp1buff;			/* M line : set tmp1="" */
	tmp1.len_used = 0;
	tmp1.len_alloc = sizeof(tmp1buff);
	words_tmp1.buf_addr = &words_tmp1buff[0];
	words_tmp1.len_used = 0;
	words_tmp1.len_alloc = sizeof(words_tmp1buff);
	null.buf_addr = NULL;
	null.len_used = 0;
	null.len_alloc = 0;
	do
	{
		status = ydb_subscript_next_s(&words, 1, &tmp1, &tmp1);	/* M line : set tmp1=$order(words(tmp1)) */
		if (YDB_ERR_NODEEND == status)
			break;
		YDB_ASSERT(YDB_OK == status);
		YDB_ASSERT(0 != tmp1.len_used);
		status = ydb_get_s(&words, 1, &tmp1, &words_tmp1);	/* M line : set words_tmp1=words(tmp1) */
		YDB_ASSERT(YDB_OK == status);
		index_subscr[0] = words_tmp1;
		index_subscr[1] = tmp1;
		status = ydb_set_s(&index, 2, index_subscr, &null);	/* M line : set index(words_tmp1,tmp1)="" */
		YDB_ASSERT(YDB_OK == status);
	} while (1);
	do
	{
		status = ydb_subscript_previous_s(&index, 1, &tmp1, &tmp1);	/* M line : set tmp1=$order(index(tmp1),-1) */
		if (YDB_ERR_NODEEND == status)
			break;
		YDB_ASSERT(YDB_OK == status);
		YDB_ASSERT(0 != tmp1.len_used);
		tmp2.buf_addr = tmp2buff;			/* M line : set tmp2="" */
		tmp2.len_used = 0;
		tmp2.len_alloc = sizeof(tmp2buff);
		index_subscr[0] = tmp1;
		index_subscr[1] = tmp2;
		do
		{
			status = ydb_subscript_next_s(&index, 2, index_subscr, &tmp2); /* M line : set tmp2=$order(index(tmp1,tmp2)) */
			if (YDB_ERR_NODEEND == status)
				break;
			YDB_ASSERT(YDB_OK == status);
			YDB_ASSERT(0 != tmp2.len_used);
			tmp1.buf_addr[tmp1.len_used] = '\0';
			tmp2.buf_addr[tmp2.len_used] = '\0';
			printf("%s\t%s\n", tmp1.buf_addr, tmp2.buf_addr);
			index_subscr[1] = tmp2;
		} while (1);
	} while (1);
	return YDB_OK;
}
