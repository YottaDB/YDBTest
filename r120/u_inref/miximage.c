/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries. *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <dlfcn.h>

#include "libyottadb.h"

#define ERRBUF_SIZE	1024

typedef int (*exe_main_t)(int argc, char **argv, char **envp);

ydb_status_t main(int argc, char **argv, char **envp)
{
	ydb_status_t	status;
	char		errbuf[ERRBUF_SIZE];
	char		*fptr;
	exe_main_t	exe_main;

	status = ydb_init();
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
		return -1;
	}
	status = ydb_ci("miximagecallin");
	if (status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
		fflush(stdout);
		return -1;
	}
	fflush(stdout);	/* flush output from above "miximagecallin" M program invocation */
	exe_main = (exe_main_t)dlsym(RTLD_DEFAULT, argv[1]);
	if (NULL == exe_main)
	{
		fprintf(stderr, "%%YDB-E-DLLNORTN, Failed to look up the location of the symbol %s\n", argv[1]);
		if ((fptr = dlerror()) != NULL)
			fprintf(stderr, "%%YDB-E-TEXT, %s\n", fptr);
		return -1;
	}
	status = exe_main(argc, argv, envp);	/* this should issue MIXIMAGE error and exit the process */
	return 0;
}
