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
#include <stdlib.h>	/* for "atoi" */

#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */

#define BASEVAR 	"^tp3"
#define VALUE1		"TP with comma-separated list of variable names to be preserved"

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

ydb_buffer_t	basevar, value1, x1var, x2var, y2var, starvar;

int	gvnset();
int	gvnset1();
int	gvnset2();
int	gvnset3();
int	gvnset4();

/* Function to test that list of variable names to be preserved (across TP restarts) works fine */
int main()
{
	int		status, i;
	ydb_string_t	zwrarg;
	ydb_buffer_t	varnames[50];
	char		sprintfbuff[1024], *spfbufptr;

	/* Initialize varname, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);
	YDB_LITERAL_TO_BUFFER("x1", &x1var);
	YDB_LITERAL_TO_BUFFER("x2", &x2var);
	YDB_LITERAL_TO_BUFFER("y2", &y2var);
	YDB_LITERAL_TO_BUFFER("*", &starvar);

	status = ydb_tp_s(&gvnset1, NULL, NULL, 1, &x1var);
	assert(YDB_OK == status);
	/* NARSTODO: Need to test kills of variables when ydb_kill_s() is available */
	/* NARSTODO: Need tests for below list of variable names to be preserved */
	varnames[0] = x2var;
	varnames[1] = y2var;
	varnames[2] = x1var;
	status = ydb_tp_s(&gvnset, NULL, NULL, 3, (ydb_buffer_t *)&varnames);
	assert(YDB_OK == status);
	status = ydb_tp_s(&gvnset, NULL, NULL, 1, &starvar);
	assert(YDB_OK == status);
	for (i = 0, spfbufptr = sprintfbuff; 50 > i; i++)
	{	/* Generate ydb_buff_t for each of x1 to x50 */
		varnames[i].buf_addr = spfbufptr;
		varnames[i].len_used = varnames[i].len_alloc = sprintf(spfbufptr, "x%i", i + 1);
		spfbufptr += varnames[i].len_used;
	}
	status = ydb_tp_s(&gvnset, NULL, NULL, 50, (ydb_buffer_t *)&varnames);
	assert(YDB_OK == status);
	return status;
}

int gvnset1()
{
	int		status, dlr_trestart;
	ydb_buffer_t	dollar_trestart, ret_value;
	char		ret_value_buff[1024];

	/* This TP transaction is done with "x" as local variable to be preserved across restarts. Test that works. */

	/* Display $TRESTART */
	YDB_LITERAL_TO_BUFFER("$TRESTART", &dollar_trestart);
	ret_value.buf_addr = ret_value_buff;
	ret_value.len_used = 0;
	ret_value.len_alloc = sizeof(ret_value_buff);
	status = ydb_get_s(&dollar_trestart, 0, NULL, &ret_value);
	ret_value.buf_addr[ret_value.len_used] = '\0';
	dlr_trestart = atoi(ret_value.buf_addr);
	assert(YDB_OK == status);
	printf("TSTART : dollar_trestart = %s\n", ret_value.buf_addr);

	/* Test that "x" is UNDEFINED at this point (even if we come in after a restart) */
	status = ydb_get_s(&x1var, 0, NULL, &ret_value);
	assert(YDB_ERR_LVUNDEF == status);
	printf("  --> Verifying x is UNDEFINED\n");

	/* Set "x" to a value */
	status = ydb_set_s(&x1var, 0, NULL, &value1);
	assert(YDB_OK == status);
	printf("  --> set x to a value\n");

	/* Test that "x" is DEFINED at this point */
	status = ydb_get_s(&x1var, 0, NULL, &ret_value);
	assert(YDB_OK == status);
	printf("  --> Verifying x is DEFINED\n");

	if (2 > dlr_trestart)
	{
		printf("  --> Signaling a TP restart\n");
		return YDB_TP_RESTART;
	}
	printf("  --> Committing the TP transaction\n");
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
