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

/* ydb_node_previous_s() of a local variable node that does not exist must return an ancestor of that
 * node that has a value but no descendants, as that ancestor collates immediately before the node.
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
	printf("WRONG : %s returned %d subscript(s) : %s, expected %d subscript(s) starting with %s\n", desc,
		ret_nsubs, actual, expected_nsubs, expected[0]);
}

int main()
{
	char	*xdeep[] = {"5", "-1", "b", "-2"}, *xa[] = {"a"}, *xa4[] = {"a", "4"}, *xa5[] = {"a", "5"};
	char	*w1[] = {"1"}, *w2[] = {"2"}, *w2xy[] = {"2", "x", "y"};

	set_node("x", 4, xdeep);
	set_node("x", 1, xa);
	check_previous("ydb_node_previous_s() of x(\"a\",4)", "x", 2, xa4, 1, xa);
	set_node("y", 1, xa);
	check_previous("ydb_node_previous_s() of y(\"a\",4)", "y", 2, xa4, 1, xa);
	set_node("w", 1, w1);
	set_node("w", 1, w2);
	check_previous("ydb_node_previous_s() of w(2,\"x\",\"y\")", "w", 3, w2xy, 1, w2);
	set_node("x", 2, xa5);
	check_previous("ydb_node_previous_s() of x(\"a\",4) after setting x(\"a\",5)", "x", 2, xa4, 1, xa);
	return 0;
}
