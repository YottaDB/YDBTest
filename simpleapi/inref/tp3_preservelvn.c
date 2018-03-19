/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "libyottadb.h"
#include "libydberrors.h"	/* for YDB_ERR_LVUNDEF */

#include <stdio.h>
#include <time.h>	/* needed for "time" */
#include <stdlib.h>	/* for "atoi" and "drand48" */
#include <unistd.h>	/* needed for "getpid" */

#define BASEVAR 	"^tp3"
#define VALUE1		"TP with comma-separated list of variable names to be preserved"

ydb_buffer_t	basevar, value1, x0var, x1var, x2var, starvar;
ydb_buffer_t	varnames[YDB_MAX_NAMES + 1];

int	gvnset();
int	gvnset1();
int	gvnset2();
int	gvnset3();
void	lvnZWRITE(void);

/* Function to test that list of variable names to be preserved (across TP restarts) works fine */
int main()
{
	int		status, i;
	ydb_string_t	zwrarg;
	char		sprintfbuff[1024], *spfbufptr;
	int		seed;

	seed = (time(NULL) * getpid());
	srand48(seed);

	/* Initialize varname, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);
	YDB_LITERAL_TO_BUFFER("x0", &x0var);
	YDB_LITERAL_TO_BUFFER("x1", &x1var);
	YDB_LITERAL_TO_BUFFER("x2", &x2var);
	YDB_LITERAL_TO_BUFFER("*", &starvar);

	/* Set "x0" to a value */
	printf("  --> set x0 to a value\n");
	status = ydb_set_s(&x0var, 0, NULL, NULL);
	YDB_ASSERT(YDB_OK == status);
	/* Set "x2" to a value */
	printf("  --> set x2 to a value\n");
	status = ydb_set_s(&x2var, 0, NULL, NULL);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_tp_s(&gvnset1, NULL, NULL, 1, &x1var);
	YDB_ASSERT(YDB_OK == status);
	for (i = 1, spfbufptr = sprintfbuff; YDB_MAX_NAMES >= i; i++)
	{	/* Generate ydb_buff_t for each of x1, x2, ... xN where N is YDB_MAX_NAMES */
		varnames[i].buf_addr = spfbufptr;
		varnames[i].len_used = varnames[i].len_alloc = sprintf(spfbufptr, "x%i", i);
		spfbufptr += varnames[i].len_used;
	}
	/* Get deterministic state before invoking gvnset2 */
	status = ydb_delete_s(&x1var, 0, NULL, YDB_DEL_TREE);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_tp_s(&gvnset2, NULL, NULL, YDB_MAX_NAMES, (ydb_buffer_t *)&varnames[1]);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_tp_s(&gvnset2, NULL, NULL, 1, &starvar);
	YDB_ASSERT(YDB_OK == status);
	return status;
}

int gvnset1()
{
	int		status, dlr_trestart;
	ydb_buffer_t	dollar_trestart, ret_value;
	char		ret_value_buff[1024];
	int		choice;

	/* This TP transaction is done with "x" as local variable to be preserved across restarts. Test that works. */

	/* Display $TRESTART */
	YDB_LITERAL_TO_BUFFER("$TRESTART", &dollar_trestart);
	ret_value.buf_addr = ret_value_buff;
	ret_value.len_used = 0;
	ret_value.len_alloc = sizeof(ret_value_buff);
	status = ydb_get_s(&dollar_trestart, 0, NULL, &ret_value);
	ret_value.buf_addr[ret_value.len_used] = '\0';
	dlr_trestart = atoi(ret_value.buf_addr);
	YDB_ASSERT(YDB_OK == status);
	printf("TSTART : dollar_trestart = %s\n", ret_value.buf_addr);

	/* Test that "x1" is UNDEFINED at this point (even if we come in after a restart) */
	printf("  --> Verifying x1 is UNDEFINED\n");
	status = ydb_get_s(&x1var, 0, NULL, &ret_value);
	YDB_ASSERT(YDB_ERR_LVUNDEF == status);

	printf("  --> Verifying x2 is UNCHANGED after restart\n");
	status = ydb_get_s(&x2var, 0, NULL, &ret_value);
	YDB_ASSERT(YDB_OK == status);
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("  --> x2 = %s\n", ret_value.buf_addr);

	printf("  --> Increment x2\n");
	status = ydb_incr_s(&x2var, 0, NULL, NULL, &ret_value);

	/* Set "x1" to a value */
	printf("  --> set x1 to a value\n");
	status = ydb_set_s(&x1var, 0, NULL, &value1);
	YDB_ASSERT(YDB_OK == status);

	/* Test that "x1" is DEFINED at this point */
	printf("  --> Verifying x1 is DEFINED\n");
	status = ydb_get_s(&x1var, 0, NULL, &ret_value);
	YDB_ASSERT(YDB_OK == status);

	/* Randomly choose to kill or zkill or nothing */
	choice = (3 * drand48());
	if (0 == choice)
		status = ydb_delete_s(&x1var, 0, NULL, YDB_DEL_TREE);
	else if (1 == choice)
		status = ydb_delete_s(&x1var, 0, NULL, YDB_DEL_NODE);
	/* else do nothing */
	YDB_ASSERT(YDB_OK == status);

	if (2 > dlr_trestart)
	{
		printf("  --> Signaling a TP restart\n");
		return YDB_TP_RESTART;
	}
	printf("  --> Committing the TP transaction\n");
	return status;
}

int gvnset2()
{
	int		status, dlr_trestart, i;
	ydb_buffer_t	dollar_trestart, ret_value;
	char		ret_value_buff[1024];
	int		choice;

	/* This TP transaction is done with "x" as local variable to be preserved across restarts. Test that works. */

	/* Display $TRESTART */
	YDB_LITERAL_TO_BUFFER("$TRESTART", &dollar_trestart);
	ret_value.buf_addr = ret_value_buff;
	ret_value.len_used = 0;
	ret_value.len_alloc = sizeof(ret_value_buff);
	status = ydb_get_s(&dollar_trestart, 0, NULL, &ret_value);
	ret_value.buf_addr[ret_value.len_used] = '\0';
	dlr_trestart = atoi(ret_value.buf_addr);
	YDB_ASSERT(YDB_OK == status);
	printf("TSTART : dollar_trestart = %s\n", ret_value.buf_addr);

	printf("Do ZWRITE of lvns\n");
	lvnZWRITE();

	printf("  --> Verifying x0 is UNCHANGED after restart\n");
	status = ydb_get_s(&x0var, 0, NULL, &ret_value);
	YDB_ASSERT(YDB_OK == status);
	ret_value.buf_addr[ret_value.len_used] = '\0';
	printf("  --> x0 = %s\n", ret_value.buf_addr);

	printf("  --> Increment x0\n");
	status = ydb_incr_s(&x0var, 0, NULL, NULL, &ret_value);

	printf("  --> Increment x1, x2, ..., x35\n");
	printf("  --> set x1, x2, ... x35 to a value\n");
	printf("  --> Verifying x1, x2, ... x35 is DEFINED\n");
	for (i = 1; YDB_MAX_NAMES >= i; i++)
	{
		status = ydb_set_s(&varnames[i], 0, NULL, &value1);
		YDB_ASSERT(YDB_OK == status);

		status = ydb_get_s(&varnames[i], 0, NULL, &ret_value);
		YDB_ASSERT(YDB_OK == status);
		choice = (i % 3);
		if (0 == choice)
			status = ydb_delete_s(&varnames[i], 0, NULL, YDB_DEL_TREE);
		else if (1 == choice)
			status = ydb_delete_s(&varnames[i], 0, NULL, YDB_DEL_NODE);
		/* else do nothing */
		YDB_ASSERT(YDB_OK == status);
	}
	printf("Do ZWRITE of lvns\n");
	lvnZWRITE();
	if (2 > dlr_trestart)
	{
		printf("  --> Signaling a TP restart\n");
		return YDB_TP_RESTART;
	}
	printf("  --> Committing the TP transaction\n");
	printf("Do ZWRITE of lvns\n");
	lvnZWRITE();

	return status;
}

/* Function to set a global variable */
int gvnset()
{
	int		status;

	/* Set a base variable, no subscripts */
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	return status;
}
