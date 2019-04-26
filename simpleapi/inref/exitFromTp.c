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

int exitFn();

/* uses ydb_tp_s() to call ydb_exit()
 * ydb_tp_s should return YDB_OK
 * then checks that exitFn()
 * was called properly using ydb_get_s()
 */
int main(){
	ydb_tpfnptr_t exitPtr;
	int status;

	exitPtr = &exitFn;
	status = ydb_tp_s(exitPtr, NULL, NULL, 0, NULL);
	YDB_ASSERT(status == YDB_OK);
	printf("ydb_tp_s() returned YDB_OK as expected\n");

	ydb_buffer_t basevar, outvalue;
	char errbuf[2048];
	char outbuf[64];
	outvalue.buf_addr = &outbuf[0];
	outvalue.len_used = 0;
	outvalue.len_alloc = sizeof(outbuf);
	YDB_LITERAL_TO_BUFFER("^a", &basevar);

	status = ydb_get_s(&basevar, 0, NULL, &outvalue);
	outvalue.buf_addr[outvalue.len_used] = '\0';
	if(strcmp(outvalue.buf_addr, "qwerty") == 0){
		printf("ydb_get_s() still works\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_get_s() failed with error code: %s\nShould have been: YDB_OK\n", errbuf);
	}
	return 0;
}

/* is called by ydb_tp_s()
 * calls ydb_exit() and checks its status
 * which should be -YBD_ERR_INVYDBEXIT
 * also performs a ydb_set_s()
 * to check that the tp is intact
 */
int exitFn(){
	int status;
	char errbuf[2048];

	/* ydb_exit check */
	status = ydb_exit();
	if(status == -YDB_ERR_INVYDBEXIT){
		printf("ydb_exit() inside ydb_tp_s() returned -YDB_ERR_INVYDBEXIT as expected\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_exit() returned wrong error code: %s\nShould have been: -YDB_ERR_INVYDBEXIT\n", errbuf);
	}

	/* checks that the tp still works */
	ydb_buffer_t basevar, value;
	YDB_LITERAL_TO_BUFFER("^a", &basevar);
	YDB_LITERAL_TO_BUFFER("qwerty", &value);

	status = ydb_set_s(&basevar, 0, NULL, &value);
	if(status == YDB_OK){
		printf("ydb_set_s() still works\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_set_s() failed with error code: %s\nShould have been: YDB_OK\n", errbuf);
	}
	return 0;
}
