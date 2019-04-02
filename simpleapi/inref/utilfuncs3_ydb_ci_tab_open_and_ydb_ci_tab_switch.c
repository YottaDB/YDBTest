/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	*
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

#define ERRBUF_SIZE	1024
#define	NUMTABLES	3

int main()
{
	int			i, status;
	uintptr_t		ret_handle[NUMTABLES], old_handle[NUMTABLES], prev_handle;
	char			errbuf[ERRBUF_SIZE];
	char			citabstr[16];

	printf("### Test Functionality of ydb_ci_tab_open()/ydb_ci_tab_switch() in the SimpleAPI ###\n"); fflush(stdout);

	printf("\n# ydb_ci_tab_switch() : Test that passing NULL as new_handle returns YDB_OK if default call-in table file [callin.tab] is not yet open\n"); fflush(stdout);
	status = ydb_ci_tab_switch((uintptr_t)NULL, &prev_handle);
	if (YDB_OK == status)
		printf("Got YDB_OK as expected\n");
	else
		printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
	fflush(stdout);

	printf("\n# Create call-in table files citable1.tab thru citable%d.tab\n", NUMTABLES);
	printf("# Create M routines citable1.m thru citable%d.m\n", NUMTABLES);
	printf("# Open default call-in table using env var ydb_ci\n");

	status = ydb_ci("citabcreate", NUMTABLES);
	YDB_ASSERT(YDB_OK == status);

	printf("\n# ydb_ci_tab_open() : Test of YDB_ERR_PARAMINVALID error for NULL fname\n");
	status = ydb_ci_tab_open(NULL, &ret_handle[0]);
	if (YDB_ERR_PARAMINVALID == status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Got YDB_ERR_PARAMINVALID error as expected : ydb_zstatus() returned : %s\n", errbuf);
	} else
		printf("Line [%d]: Expected error return [%d] but Actual return [%d]\n", __LINE__, YDB_ERR_PARAMINVALID, status);
	fflush(stdout);

	printf("\n# ydb_ci_tab_open() : Test of YDB_ERR_PARAMINVALID error for NULL ret_handle\n");
	status = ydb_ci_tab_open("", NULL);
	if (YDB_ERR_PARAMINVALID == status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Got YDB_ERR_PARAMINVALID error as expected : ydb_zstatus() returned : %s\n", errbuf);
	} else
		printf("Line [%d]: Expected error return [%d] but Actual return [%d]\n", __LINE__, YDB_ERR_PARAMINVALID, status);
	fflush(stdout);

	printf("\n# ydb_ci_tab_switch() : Test of YDB_ERR_PARAMINVALID error for NULL ret_old_handle\n");
	status = ydb_ci_tab_switch(0, NULL);
	if (YDB_ERR_PARAMINVALID == status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Got YDB_ERR_PARAMINVALID error as expected : ydb_zstatus() returned : %s\n", errbuf);
	} else
		printf("Line [%d]: Expected error return [%d] but Actual return [%d]\n", __LINE__, YDB_ERR_PARAMINVALID, status);
	fflush(stdout);

	printf("\n# ydb_ci_tab_switch() : Test of YDB_ERR_PARAMINVALID error for Invalid new_handle\n");
	status = ydb_ci_tab_switch((uintptr_t)&status, &old_handle[0]);
	if (YDB_ERR_PARAMINVALID == status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Got YDB_ERR_PARAMINVALID error as expected : ydb_zstatus() returned : %s\n", errbuf);
	} else
		printf("Line [%d]: Expected error return [%d] but Actual return [%d]\n", __LINE__, YDB_ERR_PARAMINVALID, status);
	fflush(stdout);

	for (i = 1; i <= NUMTABLES; i++)
	{
		snprintf(citabstr, sizeof(citabstr), "citable%d.tab", i);
		printf("\n# ydb_ci_tab_open() : Test that valid call-in table file %s returns YDB_OK\n", citabstr);
		fflush(stdout);
		status = ydb_ci_tab_open(citabstr, &ret_handle[i - 1]);
		if (YDB_OK == status)
			printf("Got YDB_OK as expected\n");
		else
			printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
		fflush(stdout);
	}

	snprintf(citabstr, sizeof(citabstr), "citable%d.tab", i);
	printf("\n# ydb_ci_tab_open() : Test that non-existent call-in table file %s returns YDB_ERR_CITABOPN\n", citabstr);
	fflush(stdout);
	status = ydb_ci_tab_open(citabstr, &ret_handle[0]);
	if (YDB_ERR_CITABOPN == status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Got YDB_ERR_CITABOPN error as expected : ydb_zstatus() returned : %s\n", errbuf);
	} else
		printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_ERR_CITABOPN, status);
	fflush(stdout);

	for (i = 1; i <= NUMTABLES; i++)
	{
		snprintf(citabstr, sizeof(citabstr), "citable%d.tab", i);
		printf("\n# ydb_ci_tab_switch() : Test switch to valid call-in table file %s returns YDB_OK\n", citabstr);
		fflush(stdout);
		status = ydb_ci_tab_switch(ret_handle[i - 1], &old_handle[i - 1]);
		if (YDB_OK == status)
			printf("Got YDB_OK as expected\n");
		else
			printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
		fflush(stdout);

		printf("\n# Test that ydb_ci() call uses call-in table from %s\n", citabstr);
		fflush(stdout);
		status = ydb_ci("crtnname");
		if (YDB_OK == status)
			printf("Got YDB_OK as expected\n");
		else
			printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
		fflush(stdout);
	}

	for (i = NUMTABLES; i >= 1; i--)
	{
		snprintf(citabstr, sizeof(citabstr), "citable%d.tab", i);
		printf("\n# ydb_ci_tab_switch() : Test switch to valid call-in table file %s returns YDB_OK\n", citabstr);
		fflush(stdout);
		status = ydb_ci_tab_switch(ret_handle[i - 1], &old_handle[i - 1]);
		if (YDB_OK == status)
			printf("Got YDB_OK as expected\n");
		else
			printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
		fflush(stdout);

		printf("\n# Test that ydb_ci() call uses call-in table from %s\n", citabstr);
		fflush(stdout);
		status = ydb_ci("crtnname");
		if (YDB_OK == status)
			printf("Got YDB_OK as expected\n");
		else
			printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
		fflush(stdout);
	}

	printf("\n# ydb_ci_tab_switch() : Test that passing NULL as new_handle returns YDB_OK even if default call-in:"
			"table file [callin.tab] has already been opened\n"); fflush(stdout);
	status = ydb_ci_tab_switch(prev_handle, &ret_handle[0]);
	if (YDB_OK == status)
		printf("Got YDB_OK as expected\n");
	else
		printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
	fflush(stdout);

	printf("\n# Temporarily rename default call-in table file [callin.tab] as [tmpcallin.tab]\n"); fflush(stdout);
	status = rename("callin.tab", "tmpcallin.tab");
	if (0 == status)
		printf("Got 0 return from rename(callin.tab, tmpcallin.tab) as expected\n");
	else
		printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, 0, status);
	fflush(stdout);

	printf("\n# Test that already open default call-in table is still accessible for ydb_ci() calls\n"); fflush(stdout);
	status = ydb_ci("citabtest");
	if (YDB_OK == status)
		printf("Got YDB_OK as expected\n");
	else
		printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
	fflush(stdout);

	printf("\n# Test that ydb_ci() calls that rely on non-default call-in table fail when used with default call-in table\n"); fflush(stdout);
	status = ydb_ci("crtnname");
	if (-YDB_ERR_CINOENTRY == status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Got -YDB_ERR_CINOENTRY error as expected : ydb_zstatus() returned : %s\n", errbuf);
	} else
		printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, YDB_OK, status);
	fflush(stdout);

	printf("\n# Rename default call-in table file back from [tmpcallin.tab] to [callin.tab]\n"); fflush(stdout);
	status = rename("tmpcallin.tab", "callin.tab");
	if (0 == status)
		printf("Got 0 return from rename(tmpcallin.tab, callin.tab) as expected\n");
	else
		printf("Line [%d]: Expected return [%d] but Actual return [%d]\n", __LINE__, 0, status);
	fflush(stdout);

	return YDB_OK;
}
