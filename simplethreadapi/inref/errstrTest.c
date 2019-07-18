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
#include <pthread.h>
#include <unistd.h>
#include "libyottadb.h"

#define THREADS_TO_MAKE 10

void* threadDriverA(void* args);
void* threadDriverB(void* args);

int doRun; // global that threads check to know when to stop

int main(){
	pthread_t tids[THREADS_TO_MAKE * 2];
	int i, status;

	status = ydb_init();
	YDB_ASSERT(YDB_OK == status);

	doRun = 1;
	for (i = 0; i < THREADS_TO_MAKE * 2; i+=2){
		status = pthread_create(&tids[i], NULL, &threadDriverA, NULL);
		YDB_ASSERT(0 == status);
		status = pthread_create(&tids[i+1], NULL, &threadDriverB, NULL);
		YDB_ASSERT(0 == status);
	}
	sleep(5);
	doRun = 0;
	for (i = 0; i < THREADS_TO_MAKE * 2; i++){
		status = pthread_join(tids[i], NULL);
		YDB_ASSERT(0 == status);
	}
	return 0;
}

void* threadDriverA(void* args){
	ydb_buffer_t errstr, basevar, retval;
	int i, status;
	YDB_MALLOC_BUFFER(&errstr, 1024);
	YDB_MALLOC_BUFFER(&retval, 5);
	YDB_LITERAL_TO_BUFFER("^MyVal", &basevar);

	while (doRun) {
		errstr.len_alloc = 1024;
		status = ydb_get_st(YDB_NOTTP, &errstr, &basevar, 0, NULL, &retval);
		YDB_ASSERT(YDB_OK != status);
		if (NULL == strstr(errstr.buf_addr, "%YDB-E-GVUNDEF"))
			printf("FAIL: errstr does not contain \"%%YDB-E-GVUNDEF\"; Contents of errstr.buf_addr: %s\n", errstr.buf_addr);
		errstr.len_alloc = 5;
		status = ydb_get_st(YDB_NOTTP, &errstr, &basevar, 0, NULL, &retval);
		YDB_ASSERT(YDB_OK != status);
		if (77 != errstr.len_used)
			printf("FAIL: errstr.len_used is not correct. Expected: 77; Got: %d\n", errstr.len_used);
	}
	YDB_FREE_BUFFER(&errstr);
	YDB_FREE_BUFFER(&retval);
	return 0;
}

void* threadDriverB(void* args){
	ydb_buffer_t errstr, basevar, retval, val;
	int i, status;

	YDB_LITERAL_TO_BUFFER("^MyVal2", &basevar);
	YDB_LITERAL_TO_BUFFER("1234567890", &val);
	YDB_MALLOC_BUFFER(&errstr, 1024);
	YDB_MALLOC_BUFFER(&retval, 5);

	status = ydb_set_st(YDB_NOTTP, &errstr, &basevar, 0, NULL, &val);
	YDB_ASSERT(YDB_OK == status);

	while (doRun) {
		status = ydb_get_st(YDB_NOTTP, &errstr, &basevar, 0, NULL, &retval);
		YDB_ASSERT(YDB_OK != status);
		if (NULL == strstr(errstr.buf_addr, "%YDB-E-INVSTRLEN"))
			printf("FAIL: errstr does not contain \"%%YDB-E-INVRSTRLEN\"; Contents of errstr.buf_addr: %s\n", errstr.buf_addr);
	}

	YDB_FREE_BUFFER(&errstr);
	YDB_FREE_BUFFER(&retval);
	return 0;
}
