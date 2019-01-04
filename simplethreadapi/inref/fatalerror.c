/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.*
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

char            errbuf[1024];
int             gvnset();
ydb_tp2fnptr_t   tpfn;

#define ERRBUF_SIZE     1024

char    errbuf[ERRBUF_SIZE];

int main()
{
        int	status;

	printf(" ### Test FATALERROR1 error ###\n"); fflush(stdout);
	printf(" # This test triggers a YDB-F-MEMORY error which then sends the FATALERROR1 message to syslog #\n"); fflush(stdout);
        tpfn = &gvnset;
        status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, NULL, 0, NULL);
        ydb_zstatus(errbuf, ERRBUF_SIZE);
        printf("status = %d : %s\n", status, errbuf);
        fflush(stdout);
        return status;
}

/* Function to set a global variable */
int gvnset(uint64_t tptoken, ydb_buffer_t *errstr)
{
        int             status, i;
        ydb_buffer_t    basevar, value;
        ydb_buffer_t    subs;
        char            subsbuff[16];

        YDB_LITERAL_TO_BUFFER("basevar", &basevar);
        subs.buf_addr = &subsbuff[0];
        subs.len_used = 0;
        subs.len_alloc = sizeof(subsbuff);

	printf(" # Set subscripts indefinitely to trigger a YDB-F-MEMORY error #\n"); fflush(stdout);
        for (i = 0; ; i++)
        {
                subs.len_used = sprintf(subs.buf_addr, "%d", i);
                ydb_set_st(tptoken, errstr, &basevar, 1, &subs, NULL);
        }
}
