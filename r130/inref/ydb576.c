/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>	/* needed by drand48() and srand48() calls */
#include <time.h>	/* for time() call */
#include <unistd.h>	/* for getpid() call */

#include "libyottadb.h"

#define BASEVAR "^trigbl"
#define VALUE1	"abc|d"
#define VALUE2	"e|fgh"

void set(ydb_buffer_t *varname, ydb_buffer_t *value, int depth);

int main()
{
	int		i, seed, depth1, depth2, numsets;
	ydb_buffer_t	basevar, value;
	char		buff[sizeof(VALUE1)];

	printf("# This test sets 2 different values both of the same length but having different first piece length\n");
	printf("# In order to exercise the bug, this test does the ydb_set_s() call at different C-stack depths\n");
	printf("# And initializes some memory in the C-stack at each depth to some non-zero value\n");
	printf("# And uses random recursion depths for enhanced testing\n");
	printf("# Without the code fixes of YDB#576, this test used to reliably fail with dbg and/or pro builds\n");
	/* Initialize varname, subscript, and value buffers */
	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	value.len_used = sizeof(VALUE1) - 1;
	value.len_alloc = sizeof(buff);
	value.buf_addr = buff;

	seed = (time(NULL) * getpid());	/* Establish random seed */
	srand48(seed);
	depth1 = 100 * drand48() + 1;
	depth2 = 100 * drand48() + 1;
	numsets = 1000 * drand48() + 1;

	for (i = 0; i < numsets; i++) {
		/* Ensure both "set()" calls use the same buffer address. This is needed as otherwise the check in
		 * op_fnzp1.c will see the input buffer address is different and skip going into the optimization code path
		 * and returning a pre-computed incorrect piece.
		 * Hence copying the different literals to same buffer.
		 */
		memcpy(buff, VALUE1, sizeof(buff));
		set(&basevar, &value, i % depth1);
		memcpy(buff, VALUE2, sizeof(buff));
		set(&basevar, &value, i % depth2);
	}
	return 0;
}

void set(ydb_buffer_t *varname, ydb_buffer_t *value, int depth)
{
	int		i, status;
	char		dummybuff[1024];

	for (i = 0; i < sizeof(dummybuff); i++)
		dummybuff[i] = i;	/* this is where we initialize the C-stack memory at each depth to some non-zero value */
	if (!depth)
	{	/* Recursion  end reached. Do the SimpleAPI call that invokes database trigger. */
		status = ydb_set_s(varname, 0, NULL, value);
		YDB_ASSERT(YDB_OK == status);
	} else
		set(varname, value, depth - 1);
	return;
}
