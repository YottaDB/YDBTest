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

#include "libyottadb.h"	/* for ydb_* macros/prototypes/typedefs */

#include <stdio.h>	/* for "printf" */
#include <unistd.h>	/* for "sysconf" */
#include <stdlib.h>	/* for "atoi" */

#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

/*
 * Find the maximum number of steps for the 3n+1 problem for all integers through two input integers.
 * See http://docs.google.com/View?id=dd5f3337_24gcvprmcw
 * Assumes input format is 2 integers separated by a space with the first integer smaller than the second.
 * No input error checking is done.
 *
 * Although the problem can be solved by using strictly integer subscripts and values, this program is
 * written to show that the GT.M key-value store can use arbitrary strings for both keys and values -
 * each subscript and value is spelled out using the strings in the program source line labelled "digits".
 * Furthermore, the strings are in a number of international languages when GT.M is run in UTF-8 mode.
 */

int main(int argc, char *argv[])
{
	int		blk, i, start, end, status, streams;
	ydb_buffer_t	di, ds, reads, updates, highest, zero;
	ydb_buffer_t	subscr[2], value;
	char		valuebuff[64];
	char		*digitstrings[] = {
		"zero",
		"eins",
		"deux",
		"tres",
		"quattro",
		"пять",
		"ستة",
		"सात",
		"捌",
		"ஒன்பது",
	};

	/* Note down two input integers */
	start = atoi(argv[1]);
	end   = atoi(argv[2]);

	/* Determine # of CPUs in system. We will have as many parallel computation streams. */
	streams = (int)sysconf(_SC_NPROCESSORS_ONLN);
	assert(streams);

	/* Determine blk size */
	blk = (end - start) / streams;

	/* Initialize all array variable names we are planning to use */
	YDB_STRLIT_TO_BUFFER(&di, "di");
	YDB_STRLIT_TO_BUFFER(&ds, "ds");
	YDB_STRLIT_TO_BUFFER(&reads, "reads");
	YDB_STRLIT_TO_BUFFER(&updates, "updates");
	YDB_STRLIT_TO_BUFFER(&highest, "highest");
	YDB_STRLIT_TO_BUFFER(&zero, "0");

	/* Initialize all nodes */
	status = ydb_set_s(&reads, 0, NULL, &zero);
	assert(YDB_OK == status);
	status = ydb_set_s(&updates, 0, NULL, &zero);
	assert(YDB_OK == status);
	status = ydb_set_s(&highest, 0, NULL, &zero);
	assert(YDB_OK == status);

	/* NARSTODO: Initialize arrays to convert between strings and integers */
	for (i = 0; i <= 9; i++)
		;

	/* TEMPORARY */
	value.buf_addr = valuebuff;
	value.len_alloc = sizeof(valuebuff);
	value.len_used = 0;
	status = ydb_incr_s(&reads, 0, NULL, NULL, &value);
	assert(YDB_OK == status);
	status = ydb_incr_s(&reads, 0, NULL, NULL, &value);
	assert(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	/* TEMPORARY */

	printf ("start = %d : end = %d : streams = %d : value = %s\n", start, end, streams, value.buf_addr);

	return YDB_OK;
}
