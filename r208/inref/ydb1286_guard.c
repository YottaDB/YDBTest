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

/* ydb_zwr2str_s() must return the empty string for any input that is not a complete ZWRITE format string,
 * and must not read past the end of its input. Each input is copied to the end of a page that is followed by
 * a page with no access, so a read past the input gets a SIGSEGV. Each input is converted in its own child
 * process, so a SIGSEGV in one does not stop the others from being checked.
 */

#include "libyottadb.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/wait.h>

#define	OUTSIZE	64

typedef struct
{
	char	*zwr;		/* ZWRITE format input */
	char	*expect;	/* expected result */
} testcase;

static testcase	cases[] = {
	/* Inputs that end where the unfixed code read one byte past the end */
	{ "\"X\"_$",		"" },
	{ "\"X\"_$Z",		"" },
	{ "\"X\"_$ZC",		"" },
	{ "\"X\"_$C",		"" },
	{ "\"X\"_$C(65",	"" },
	{ "\"X\"_$ZCH(65",	"" },
	/* Inputs the unfixed code accepted without reading past the end */
	{ "\"X\"_$C(",		"" },
	{ "\"X\"_$ZCH(",	"" },
	{ "$C(65,",		"" },
	{ "\"X\"_",		"" },
	{ "\"X\"_$C(65)_",	"" },
	{ "\"X\"_\"Y",		"" },
	{ "\"a\"\"",		"" },
	{ "-",			"" },
	{ ".",			"" },
	{ "-.",			"" },
	{ "1.",			"" },
	/* Valid inputs that end with each kind of token */
	{ "\"X\"",		"X" },
	{ "\"X\"_$C(65)",	"XA" },
	{ "\"X\"_$ZCH(65,66)",	"XAB" },
	{ "\"a\"\"\"",		"a\"" },
	{ "\"\"",		"" },
	{ "-12.5",		"-12.5" },
};

/* Convert zwr, placed so that its last byte is the last accessible byte, and check the result is expect */
static int check(char *page_end, char *zwr, char *expect)
{
	ydb_buffer_t	src, dst;
	char		out[OUTSIZE];
	int		len, status;

	len = strlen(zwr);
	memcpy(page_end - len, zwr, len);
	src.buf_addr = page_end - len;
	src.len_used = src.len_alloc = len;
	dst.buf_addr = out;
	dst.len_alloc = OUTSIZE;
	dst.len_used = 0;
	status = ydb_zwr2str_s(&src, &dst);
	if (YDB_OK != status)
	{
		printf("WRONG : ydb_zwr2str_s() of %s returned status %d, expected YDB_OK\n", zwr, status);
		return 1;
	}
	if ((dst.len_used == strlen(expect)) && !memcmp(out, expect, dst.len_used))
	{
		printf("PASS : ydb_zwr2str_s() of %s returned [%.*s]\n", zwr, (int)dst.len_used, out);
		return 0;
	}
	printf("WRONG : ydb_zwr2str_s() of %s returned [%.*s], expected [%s]\n", zwr, (int)dst.len_used, out, expect);
	return 1;
}

int main(void)
{
	char	*pages;
	long	pagesize;
	int	i, stat;
	pid_t	pid;

	pagesize = sysconf(_SC_PAGESIZE);
	pages = mmap(NULL, 2 * pagesize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (MAP_FAILED == pages)
	{
		perror("mmap");
		return 1;
	}
	if (mprotect(pages + pagesize, pagesize, PROT_NONE))
	{
		perror("mprotect");
		return 1;
	}
	for (i = 0; i < (int)(sizeof(cases) / sizeof(cases[0])); i++)
	{
		fflush(stdout);
		pid = fork();
		if (0 == pid)
			exit(check(pages + pagesize, cases[i].zwr, cases[i].expect));
		/* check() exits with 0 or 1, so any other outcome means ydb_zwr2str_s() did not return */
		if ((pid != waitpid(pid, &stat, 0)) || !WIFEXITED(stat) || (1 < WEXITSTATUS(stat)))
			printf("WRONG : ydb_zwr2str_s() of %s did not return; its process ended with wait status 0x%x\n",
				cases[i].zwr, stat);
	}
	return 0;
}
