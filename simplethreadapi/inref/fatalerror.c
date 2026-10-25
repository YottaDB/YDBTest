/****************************************************************
 *								*
 * Copyright (c) 2018-2026 YottaDB LLC and/or its subsidiaries. *
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
#include <sys/resource.h>

#define VM_HEADROOM	(300 * 1024 * 1024)

char            errbuf[1024];
int             gvnset();
int		limit_vmemoryuse();
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

	/* YottaDB has initialized by now, as this function runs inside ydb_tp_st(). So limit the virtual memory of
	 * the process to 300MiB more than it uses at this point, before the loop below grows the local variable until
	 * YottaDB cannot get memory. See limit_vmemoryuse() for why the limit is relative.
	 */
	if (limit_vmemoryuse())
		return 1;
	printf(" # Set subscripts indefinitely to trigger a YDB-F-MEMORY error #\n"); fflush(stdout);
	for (i = 0; ; i++)
	{
		subs.len_used = sprintf(subs.buf_addr, "%d", i);
		ydb_set_st(tptoken, errstr, &basevar, 1, &subs, NULL);
	}
}

/* Limit the virtual memory of this process to VM_HEADROOM more than it uses now, after YottaDB has initialized.
 * The local variable that gvnset() grows gets its nodes in blocks that double in size, so with a fixed limit the
 * request that fails, and with it the memory left for the fatal error handling that follows (which writes a
 * ZSHOW dump of that variable), depends on how much memory the process used before the first node. A limit
 * relative to that makes the request for 176MiB always the one that fails, with about 124MiB left.
 */
int limit_vmemoryuse()
{
	FILE		*fp;
	char		line[256];
	unsigned long	vmsize_kb;
	struct rlimit	rl;

	fp = fopen("/proc/self/status", "r");
	if (NULL == fp)
	{
		perror("FAIL : fopen(/proc/self/status)");
		return 1;
	}
	vmsize_kb = 0;
	while (NULL != fgets(line, sizeof(line), fp))
	{
		if (1 == sscanf(line, "VmSize: %lu kB", &vmsize_kb))
			break;
	}
	fclose(fp);
	if (0 == vmsize_kb)
	{
		printf("FAIL : no VmSize line in /proc/self/status\n");
		return 1;
	}
	if (0 != getrlimit(RLIMIT_AS, &rl))
	{
		perror("FAIL : getrlimit(RLIMIT_AS)");
		return 1;
	}
	rl.rlim_cur = vmsize_kb * 1024 + VM_HEADROOM;
	if ((RLIM_INFINITY != rl.rlim_max) && (rl.rlim_max < rl.rlim_cur))
	{
		printf("FAIL : the hard RLIMIT_AS of %lu bytes is below %lu\n", (unsigned long)rl.rlim_max,
			(unsigned long)rl.rlim_cur);
		return 1;
	}
	if (0 != setrlimit(RLIMIT_AS, &rl))
	{
		perror("FAIL : setrlimit(RLIMIT_AS)");
		return 1;
	}
	return 0;
}
