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
#include "libydberrors.h"	/* for YDB_ERR_LVUNDEF */

#include <stdio.h>
#include <stdlib.h>	/* for "atoi" */

#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */

#define BASEVAR "^tp3"
#define VALUE1	"TP with comma-separated list of variable names to be preserved"

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

ydb_buffer_t	basevar, value1, x1var, x2var, y2var;

int	gvnset();
int	gvnset1();
int	gvnset2();
int	gvnset3();
int	gvnset4();

/* Function to test that list of variable names to be preserved (across TP restarts) works fine */
int main()
{
	int		status;
	ydb_string_t	zwrarg;

	/* Initialize varname, and value buffers */
	YDB_STRLIT_TO_BUFFER(&basevar, BASEVAR);
	YDB_STRLIT_TO_BUFFER(&value1, VALUE1);
	YDB_STRLIT_TO_BUFFER(&x1var, "x1");
	YDB_STRLIT_TO_BUFFER(&x2var, "x2");
	YDB_STRLIT_TO_BUFFER(&y2var, "y2");

	status = ydb_tp_s(&gvnset1, NULL, NULL, "x1");
	assert(YDB_OK == status);
	/* NARSTODO: Need to test kills of variables when ydb_kill_s() is available */
	/* NARSTODO: Need tests for below list of variable names to be preserved */
	status = ydb_tp_s(&gvnset, NULL, NULL, "x2,y2,x1");
	assert(YDB_OK == status);
	status = ydb_tp_s(&gvnset, NULL, NULL, "*");
	assert(YDB_OK == status);
	status = ydb_tp_s(&gvnset, NULL, NULL, "x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20,x21,x22,x23,x24,x25,x26,x27,x28,x29,x30,x31,x32,x33,x34,x35,x36,x37,x38,x39,x40,x41,x42,x43,x44,x45,x46,x47,x48,x49,x50");
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
	YDB_STRLIT_TO_BUFFER(&dollar_trestart, "$TRESTART");
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
