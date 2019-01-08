/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Routine to help test SimpleThreadAPI ydb_node_previous_st(). It is a call-in routine from a MUMPS main process.
 *
 * See nodeprevious.m routine for full description of the overall test and how this routine works.
 *
 * To build:
 *   gt_cc_dbg nodepreviouscb.c
 *   gcc -o nodepreviouscb.so -shared nodepreviouscb.o
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "libyottadb.h"

#define ERRBUF_SIZE	1024
#define MAX_SUB_LEN	10		/* This value needs to match the value used in nodeprevious.m when creating subs */

#define SAPI_VALIDATE_RETURN(STATUS, WHERE, EXIT)					\
{											\
	if (status)									\
	{										\
		ydb_zstatus(errbuf, ERRBUF_SIZE);					\
		printf("%s failure with rc %d and error: %s\n", WHERE, STATUS, errbuf); \
		fflush(stdout);								\
		if (EXIT)								\
			exit(1);							\
	}										\
}

static ydb_buffer_t 	subs1[YDB_MAX_SUBS], subs2[YDB_MAX_SUBS];
static int		subs_initialized;

/* This routine is a call-in so first parm is always a (ignored in this case) parameter count. Second parm is the base variable
 * (either local or global) that we are running through. Routine runs the subscripted var with ydb_node_previous_st() and dumps the
 * subscript array into a file to be compared to the similar file created by the M routine using $QUERY().
 */
void nodepreviouscb(int parmcnt, ydb_string_t *basevar_in);
void nodepreviouscb(int parmcnt, ydb_string_t *basevar_in)
{
	ydb_buffer_t	basevar, *subs_in, *subs_out, *subs_tmp;
	int		status, subs_in_cnt, subs_out_cnt, sub_idx, reccnt;
	FILE		*outfile;
	char		errbuf[ERRBUF_SIZE];

	printf("nodepreviouscb: Entered external routine\n");
	outfile = fopen("nodeprevioussublist_SAPI.txt","w");
	if (NULL == outfile)
	{	/* File did not open - signal error */
		printf("Open of output file 'nodepreviouscb.txt' failed rc = %d\n", errno);
		exit(1);
	}
	basevar.buf_addr = basevar_in->address;
	basevar.len_used = basevar.len_alloc = basevar_in->length;
	if (!subs_initialized)
	{	/* Loop to initialize both input/output subscript buffers with actual buffers. Note only the first
		 * element of both arrays actually needs the + 1 in size to create the initial search subscript
		 * created described below in the node-previous loop but it's just easier to make it apply to all
		 * of them.
		 */
		for (sub_idx = 0; YDB_MAX_SUBS > sub_idx; sub_idx++)
		{
			subs1[sub_idx].buf_addr = malloc(MAX_SUB_LEN + 1);
			subs1[sub_idx].len_alloc = MAX_SUB_LEN + 1;
			subs1[sub_idx].len_used = 0;
			subs2[sub_idx].buf_addr = malloc(MAX_SUB_LEN + 1);
			subs2[sub_idx].len_alloc = MAX_SUB_LEN + 1;
			subs2[sub_idx].len_used = 0;
		}
		subs_initialized = TRUE;
	}
	subs_in = subs1;			/* Initial alignment */
	subs_out = subs2;
	/* Set up loop to run through the subscripted nodes. Since we are running the list backwards, start
	 * with a subscript one byte longer than the maximum subscript and filled with the highest possible
	 * characters we generate our subscripts with in this test - in this case the '~' character. Generate
	 * this subscript in the subs_out array as this will become the input value when ydb_node_previous_st()
	 * is called.
	 */
	subs_out_cnt = 1;
	memset(subs_out[0].buf_addr, '~', MAX_SUB_LEN + 1);	/* Fill in the initial subscript */
	subs_out[0].len_used = subs_out[0].len_alloc = MAX_SUB_LEN + 1;
	for (reccnt = 0; ; reccnt++)
	{	/* Once through for each node - subs_in_cnt gets initialized to subs_out_cnt except for
		 * the first time through when it gets initialized to zero for the unsubscripted inital
		 * pass.
		 */
		subs_in_cnt = (YDB_MAX_SUBS >= subs_out_cnt) ? subs_out_cnt : 0;
		/* Swap the input and output subscript pointers. This takes the last set of subscripts we located
		 * and feeds them back as input for the next call.
		 */
		subs_tmp = subs_in;
		subs_in = subs_out;
		subs_out = subs_tmp;
		/* Reset our output count so all subs are available for output and make our call */
		subs_out_cnt = YDB_MAX_SUBS;
		YDB_ASSERT(0 <= subs_in_cnt);	/* Could have 0 count on last record (unsubscripted var) */
		status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, subs_in_cnt, subs_in, &subs_out_cnt, subs_out);
		if (YDB_ERR_NODEEND == status)
			break;
		SAPI_VALIDATE_RETURN(status, "ydb_node_previous()", TRUE);
		YDB_ASSERT(YDB_MAX_SUBS >= subs_out_cnt);
		YDB_ASSERT(0 <= subs_out_cnt);
		if (0 != subs_out_cnt)
		{	/* Subscripted reference - dump the subscripts space delimited - all subscripts for a given
			 * reference on one line.
			 */
			for (sub_idx = 0; subs_out_cnt > sub_idx; sub_idx++)
			{
				if (0 != sub_idx)
					fprintf(outfile, " ");
				fprintf(outfile, "%.*s", subs_out[sub_idx].len_used, subs_out[sub_idx].buf_addr);
			}
		} else
			fprintf(outfile,"<no subscripts>");
		fprintf(outfile, "\n");
	}
	fclose(outfile);
	printf("nodepreviouscb: Complete\n");
}
