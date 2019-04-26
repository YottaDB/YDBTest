/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	*
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
#include "libyottadb.h"

int initFn();

/* uses ydb_tp_st() to call ydb_init()
 * ydb_tp_st should return YDB_OK
 * then checks that initFn()
 */
int main(){
	ydb_tp2fnptr_t initPtr;
	int status;

	initPtr = &initFn;
	status = ydb_tp_st(YDB_NOTTP, NULL, initPtr, NULL, NULL, 0, NULL);
	YDB_ASSERT(status == YDB_OK);
	printf("ydb_tp_st() returned YDB_OK as expected\n");

	return 0;
}

/* is called by ydb_tp_st()
 * calls ydb_init() and checks its status
 * which should be YDB_OK
 */
int initFn(){
	int status;
	char errbuf[2048];

	/* ydb_init check */
	status = ydb_init();
	if(status == YDB_OK){
		printf("ydb_init() inside ydb_tp_st() returned YDB_OK as expected\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_init() returned wrong error code: %s\nShould have been: YDB_OK\n", errbuf);
	}

	return 0;
}
