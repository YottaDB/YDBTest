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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#undef DEBUGISV				/* Change to define to enable debugging */
#define ERRBUF_SIZE		1024
#define MAX_RETVALUE_LEN	4096	/* Hold string of return values from passed-in ISVs. Note this value must match the value
					 * being used in isvgetcb.tab where the call out is defined in isvget.csh.
					 */
#define MAX_VALUE_LEN		1024	/* Buffer to hold return value from each individual call */

#ifdef DEBUGISV
# define DBGISV(x) {printf x; fflush(stderr); fflush(stdout);}
# define DBGISV_ONLY(x) x
#else
# define DBGISV(x)
# define DBGISV_ONLY(x)
#endif

void isvgetcb(int count, ydb_string_t *ISVlist, ydb_string_t *ISVvals);
char *find_char(char fchr, char *lineptr, char *lineend);

/* Read the parameter string into a list of ISV names we are to fetch. Return a string with the delimited list of the return
 * values of those ISVs. Note we are doing fflush() after any stream output here to lessen the likelyhood of interference from
 * YDBs M output which can get intermixed with the output of this function.
 */
void isvgetcb(int count, ydb_string_t *ISVlist, ydb_string_t *ISVvals)
{
	char		*rbendptr, *rbcurptr, *listendptr, *listcurptr, *tokstart, *tokend;
	char		ISVbuffer[MAX_VALUE_LEN];
	char		errbuf[ERRBUF_SIZE];
	ydb_buffer_t	ISVname, ISVvalue;
	int		toklen, ISVcnt, status, lenavail;

	printf("isvgetcb: Entered external call - processing ISV list..\n");
	fflush(stdout);
	/* Simple argument validation */
	if (2 != count)
	{
		printf("isvgetcb: Error - insufficient arguments passed in - expecting 2, got %d\n", count);
		fflush(stdout);
		exit(1);
	}
	if (MAX_RETVALUE_LEN != ISVvals->length)
	{
		printf("isvgetcb: Error - ISVvals->length (pre-allocated buffer) not the expected length (expected %d, got %d\n",
		       MAX_RETVALUE_LEN, (int)ISVvals->length);
		fflush(stdout);
		exit(1);
	}
	if ((NULL == ISVlist) || (NULL == ISVlist->address) || (0 >= ISVlist->length))
	{
		printf("isvgetcb: Error - ISVlist is not setup correctly (missing or no list supplied)\n");
		fflush(stdout);
		exit(1);
	}
	/* Initialize things */
	rbcurptr = ISVvals->address;
	rbendptr = rbcurptr + MAX_RETVALUE_LEN;		/* Top we won't go past when adding to buffer */
	listcurptr = ISVlist->address;
	listendptr = listcurptr + ISVlist->length;	/* Top we won't read past */
	/* Parse the list pulling off each ISV name and fetching its value and adding that to the output buffer.
	 * Note the bump of rbcurptr is just to get past the delimiter char that it would otherwise be pointing to.
	 */
	for (ISVcnt = 1; (listcurptr < listendptr) && (rbcurptr < rbendptr); ISVcnt++, listcurptr++)
	{	/* Once thru for each ISV */
		tokstart = listcurptr;
		tokend = find_char('|', listcurptr, listendptr);
		toklen = tokend - tokstart;
		if (0 >= toklen)
		{	/* Likely at end of line so we have one last ISV to report on. Make sure a loop ending condition
			 * is set.
			 */
			toklen = listendptr - tokstart;
			if (0 == toklen)
				/* We must have ended on a piece marker so NO ISV exists at end of line. Just break out
				 * of this loop to be done!
				 */
				break;
			/* Else we have a "last var" to process so allow that to proceded after we set up end-of-loop
			 * situation so this is our last pass.
			 */
			tokend = listcurptr = listendptr;
		} else
			listcurptr += toklen;		/* Update continuation pointer */
		/* At this point, tokstart/tokend should define the ISV we want to query. Verify we have a name, not
		 * exceeding YDB_MAX_IDENT that starts with a '$' before passing it through.
		 */
		if ((0 >= toklen) || ((YDB_MAX_IDENT + 1) < toklen) || ('$' != *tokstart))
		{
			printf("isvgetcb: Error - invalid ISV name: %.*s\n", toklen, tokstart);
			fflush(stdout);
			exit(1);
		}
		ISVname.buf_addr = tokstart;
		ISVname.len_used = ISVname.len_alloc = toklen;
		ISVvalue.buf_addr = ISVbuffer;
		ISVvalue.len_used = ISVvalue.len_alloc = MAX_VALUE_LEN;
		status = ydb_get_s(&ISVname, 0, NULL, &ISVvalue);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("isvgetcb: Error - Fetch failed for ISV %.*s : %s\n", ISVname.len_used, ISVname.buf_addr,
			       errbuf);
			fflush(stdout);
			/* We expect some errors (SVNOSET for example) so no exit after error - keep trying */
			continue;
		}
		/* Value has been fetched - add it to our return string if it will fit */
		lenavail = rbcurptr - rbendptr - 1;		/* Hold onto one space as need room for delimiter char too */
		if (ISVvalue.len_used > lenavail)
		{
			printf("isvgetcb: Error - output value won't fit in buffer for ISV %.*s - value: %.*s/n", ISVname.len_used,
			       ISVname.buf_addr, ISVvalue.len_used, ISVvalue.buf_addr);
			exit(1);
		}
		if (rbcurptr != ISVvals->address)
		{	/* If not the first value, add a separator char */
			*rbcurptr++ = '|';
		}
		memcpy(rbcurptr, ISVvalue.buf_addr, ISVvalue.len_used);
		rbcurptr += ISVvalue.len_used;
		DBGISV(("isvgetcb: Adding ISV %.*s with value %.*s\n", ISVname.len_used, ISVname.buf_addr,
			ISVvalue.len_used, ISVvalue.buf_addr));
	}
	/* Update the used length in the output ydb_buffer_t for the return value */
	ISVvals->length = rbcurptr - ISVvals->address;
	printf("isvgetcb: Processed %d ISVs and returned a value length of %d bytes\n", ISVcnt, (int)ISVvals->length);
	fflush(stdout);
	return;
}

/* Routine to locate 'fchr' in the string defined by the start/end pair lineptr/lineend. Return NULL if
 * the character is not found in the string.
 */
char *find_char(char fchr, char *lineptr, char *lineend)
{
	int	inside_quote;

	inside_quote = FALSE;
	while(lineptr < lineend)
	{
		if (inside_quote)
		{	/* Can't find char inside quote so only look for close quote here */
			if ('"' == *lineptr)
				inside_quote = FALSE;
			lineptr++;
			continue;
		}
		if ('"' == *lineptr)
		{
			inside_quote = TRUE;
			lineptr++;
			continue;
		}
		if (fchr == *lineptr)
			return lineptr;
		lineptr++;
	}
	return lineend;			/* Character was not found */
}
