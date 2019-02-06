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

#include <stdio.h>
#include <string.h>
#include <dlfcn.h>

#include "gtmxc_types.h"
#include "libyottadb.h"

#define ERRBUF_SIZE	1024

typedef ydb_status_t	(*gtm_init_fnptr_t)(void);
typedef ydb_status_t	(*gtm_ci_fnptr_t)(const char *c_rtn_name, ...);
typedef ydb_status_t	(*gtm_cip_fnptr_t)(ci_name_descriptor *ci_info, ...);

int main(void)
{
	int			status;
	char			errbuf[ERRBUF_SIZE], dlopenstr[256];
	ci_name_descriptor	test_cid;
	void			*handle;
	gtm_init_fnptr_t	gtm_init_fnptr;
	gtm_ci_fnptr_t		gtm_ci_fnptr;
	gtm_cip_fnptr_t		gtm_cip_fnptr;

	snprintf(dlopenstr, sizeof(dlopenstr), "%s/libyottadb.so", getenv("ydb_dist"));
	handle = dlopen(dlopenstr, (RTLD_NOW | RTLD_GLOBAL));
	if (NULL == handle)
	{
		printf("dlopen(%s) failed. Exiting...\n", dlopenstr);
		return -1;
	} else
		printf("dlopen(\"libyottadb.so\") passed (returned non-NULL).\n");
	gtm_init_fnptr = (gtm_init_fnptr_t)dlsym(handle, "gtm_init");
	if (NULL == gtm_init_fnptr)
		printf("dlsym(\"gtm_init\") failed (returned NULL).\n");
	else
		printf("dlsym(\"gtm_init\") passed (returned non-NULL).\n");
	gtm_ci_fnptr = (gtm_ci_fnptr_t)dlsym(handle, "gtm_ci");
	if (NULL == gtm_ci_fnptr)
		printf("dlsym(\"gtm_ci\") failed (returned NULL).\n");
	else
		printf("dlsym(\"gtm_ci\") passed (returned non-NULL).\n");
	gtm_cip_fnptr = (gtm_cip_fnptr_t)dlsym(handle, "gtm_cip");
	if (NULL == gtm_cip_fnptr)
		printf("dlsym(\"gtm_cip\") failed (returned NULL).\n");
	else
		printf("dlsym(\"gtm_cip\") passed (returned non-NULL).\n");

	if (NULL != gtm_init_fnptr)
	{
		printf("\n# Testing gtm_init() through dlsym(\"gtm_init\")\n");
		status = (*gtm_init_fnptr)();
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("[Line %d]: %s\n", __LINE__, errbuf);
		} else
			printf("gtm_init() successful\n");
	}
	fflush(stdout);	/* Before call-in that writes to stdout, ensure all buffered output till now is flushed */

	if (NULL != gtm_ci_fnptr)
	{
		printf("\n# Testing gtm_ci() through dlsym(\"gtm_ci\")\n");
		fflush(stdout);
		status = (*gtm_ci_fnptr)("Test");
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("[Line %d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		} else
			printf("gtm_ci() successful\n");
	}

	if (NULL != gtm_cip_fnptr)
	{
		printf("\n# Testing gtm_cip() through dlsym(\"gtm_cip\")\n");
		fflush(stdout);
		test_cid.rtn_name.address = ("Test");
		test_cid.rtn_name.length = strlen(test_cid.rtn_name.address);
		test_cid.handle = NULL;
		status = (*gtm_cip_fnptr)(&test_cid);
		if (YDB_OK != status)
		{
			ydb_zstatus(errbuf, ERRBUF_SIZE);
			printf("[Line %d]: %s\n", __LINE__, errbuf);
			fflush(stdout);
		} else
			printf("gtm_cip() successful\n");
	}
	return YDB_OK;
}
