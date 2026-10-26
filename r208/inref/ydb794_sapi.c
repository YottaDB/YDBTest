/****************************************************************
 *								*
 * Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* With standard null collation, ydb_node_previous_s() of a global variable node whose last subscript is the empty
 * string and that has no value must return the last node at that level, as $QUERY(gvn,-1) does.
 */

#include "libyottadb.h"

#include <stdio.h>
#include <string.h>

#define	NRETSUBS	4
#define	RETSUBSIZE	32

/* Set varname(subs...)="1" */
static void set_node(char *varname, int nsubs, char **subs)
{
	ydb_buffer_t	var, subsarray[NRETSUBS], value;
	int		i, status;

	YDB_STRING_TO_BUFFER(varname, &var);
	for (i = 0; i < nsubs; i++)
		YDB_STRING_TO_BUFFER(subs[i], &subsarray[i]);
	YDB_LITERAL_TO_BUFFER("1", &value);
	status = ydb_set_s(&var, nsubs, subsarray, &value);
	if (YDB_OK != status)
		printf("WRONG : ydb_set_s() of %s returned status %d\n", varname, status);
}

/* Call ydb_node_previous_s() on varname(subs...) and check it returns expected_nsubs subscripts
 * that are expected[0], expected[1], ...
 */
static void check_previous(char *desc, char *varname, int nsubs, char **subs, int expected_nsubs, char **expected)
{
	ydb_buffer_t	var, subsarray[NRETSUBS], retsubs[NRETSUBS];
	char		retbuf[NRETSUBS][RETSUBSIZE], actual[256];
	int		i, status, ret_nsubs;

	YDB_STRING_TO_BUFFER(varname, &var);
	for (i = 0; i < nsubs; i++)
		YDB_STRING_TO_BUFFER(subs[i], &subsarray[i]);
	for (i = 0; i < NRETSUBS; i++)
	{
		retsubs[i].buf_addr = retbuf[i];
		retsubs[i].len_alloc = RETSUBSIZE;
		retsubs[i].len_used = 0;
	}
	ret_nsubs = NRETSUBS;
	status = ydb_node_previous_s(&var, nsubs, subsarray, &ret_nsubs, retsubs);
	if (YDB_OK != status)
	{
		printf("WRONG : %s returned status %d (%s), expected %d subscript(s)\n", desc, status,
			(YDB_ERR_NODEEND == status) ? "YDB_ERR_NODEEND" : "unexpected", expected_nsubs);
		return;
	}
	actual[0] = '\0';
	for (i = 0; i < ret_nsubs; i++)
	{
		if (i)
			strcat(actual, ",");
		strncat(actual, retsubs[i].buf_addr, retsubs[i].len_used);
	}
	if (ret_nsubs == expected_nsubs)
	{
		for (i = 0; i < ret_nsubs; i++)
			if ((strlen(expected[i]) != retsubs[i].len_used)
					|| memcmp(expected[i], retsubs[i].buf_addr, retsubs[i].len_used))
				break;
		if (i == ret_nsubs)
		{
			printf("PASS : %s returned %d subscript(s) : %s\n", desc, ret_nsubs, actual);
			return;
		}
	}
	printf("WRONG : %s returned %d subscript(s) : %s, expected %d subscript(s) : %s\n", desc,
		ret_nsubs, actual, expected_nsubs, expected[0]);
}

int main()
{
	ydb_buffer_t	var;
	char		*one[] = {"1"}, *twoone[] = {"2", "1"}, *null[] = {""}, *twonull[] = {"2", ""}, *none[] = {""};
	int		status;

	YDB_LITERAL_TO_BUFFER("^x", &var);
	status = ydb_delete_s(&var, 0, NULL, YDB_DEL_TREE);
	if (YDB_OK != status)
		printf("WRONG : ydb_delete_s() of ^x returned status %d\n", status);
	set_node("^x", 0, NULL);
	set_node("^x", 1, one);
	set_node("^x", 2, twoone);
	check_previous("ydb_node_previous_s() of ^x(\"\")", "^x", 1, null, 2, twoone);
	check_previous("ydb_node_previous_s() of ^x(2,\"\")", "^x", 2, twonull, 2, twoone);
	set_node("^x", 1, null);
	check_previous("ydb_node_previous_s() of ^x(\"\") where ^x(\"\") has a value", "^x", 1, null, 0, none);
	return 0;
}
