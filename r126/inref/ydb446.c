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
#include "libyottadb.h"

int sapi(){
	int status;
	char goodBuf[21], badBuf[15], errBuf[1024];
	ydb_string_t goodStr, badStr;
	goodStr.address = goodBuf;
	goodStr.length = 21;
	badStr.address = badBuf;
	badStr.length = 15;

	printf("\nydb_ci() tests\n");
	printf("ydb_ci() on a properly allocated buffer should return no error\n");
	status = ydb_ci("retStr", &goodStr);
	if(YDB_OK != status){
		printf("FAIL: ydb_ci() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci() returned YDB_OK\n");
	}
	goodStr.address[20] = '\0'; // null terminate for strcmp()
	if (0 != strcmp(goodStr.address, "a0a1a2a3a4a5a6a7a8a9")){
		printf("FAIL: ydb_ci() did not return the correct string. Got: %s; Expected: a0a1a2a3a4a5a6a7a8a9\n", goodStr.address);
	} else {
		printf("PASS: ydb_ci() returned the correct string\n");
	}

	printf("\nydb_ci() on a improperly (too small) buffer; should return INVSTRLEN\n");
	status = ydb_ci("retStr", &badStr);
	ydb_zstatus(errBuf, 1024);
	if(-YDB_ERR_INVSTRLEN != status){
		printf("FAIL: ydb_ci() did not return the correct status. Got: %d; Expected: %d\n", status, -YDB_ERR_INVSTRLEN);
	} else {
		printf("PASS: ydb_ci() returned INVSTRLEN\n");
	}
	if(0 != strcmp(errBuf, "150375522,(Call-In),%YDB-E-INVSTRLEN, Invalid string length 20: max 15")){
		printf("FAIL: ydb_ci() did not return the correct error message. Got: \"%s\"; Expected: "
				"\"150375522,(Call-In),%%YDB-E-INVSTRLEN, Invalid string length 20: max 15\"\n", errBuf);
	} else {
		printf("PASS: ydb_ci() returned the correct error message\n");
	}

	printf("\n\nydb_cip() tests\n");
	ci_name_descriptor callin;
	callin.rtn_name.address = "retStr";
	callin.rtn_name.length = 6;
	callin.handle = NULL;
	printf("ydb_cip() on a properly allocated buffer should return no error\n");
	status = ydb_cip(&callin, &goodStr);
	if(YDB_OK != status){
		printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_cip() returned YDB_OK\n");
	}
	goodStr.address[20] = '\0'; // null terminate for strcmp()
	if (0 != strcmp(goodStr.address, "a0a1a2a3a4a5a6a7a8a9")){
		printf("FAIL: ydb_cip() did not return the correct string. Got: %s; Expected: a0a1a2a3a4a5a6a7a8a9\n", goodStr.address);
	} else {
		printf("PASS: ydb_cip() returned the correct string\n");
	}

	printf("\nydb_cip() on a improperly (too small) buffer; should return INVSTRLEN\n");
	status = ydb_cip(&callin, &badStr);
	ydb_zstatus(errBuf, 1024);
	if(-YDB_ERR_INVSTRLEN != status){
		printf("FAIL: ydb_cip() did not return the correct status. Got: %d; Expected: %d\n", status, -YDB_ERR_INVSTRLEN);
	} else {
		printf("PASS: ydb_cip() returned INVSTRLEN\n");
	}
	if(0 != strcmp(errBuf, "150375522,(Call-In),%YDB-E-INVSTRLEN, Invalid string length 20: max 15")){
		printf("FAIL: ydb_ci() did not return the correct error message. Got: \"%s\"; Expected: "
				"\"150375522,(Call-In),i%%YDB-E-INVSTRLEN, Invalid string length 20: max 15\"\n", errBuf);
	} else {
		printf("PASS: ydb_ci() returned the correct error message\n");
	}
}

int stapi(){
	int status;
	char goodBuf[21], badBuf[15], errBuf[1024];
	ydb_string_t goodStr, badStr;
	ydb_buffer_t errstr;
	goodStr.address = goodBuf;
	goodStr.length = 21;
	badStr.address = badBuf;
	badStr.length = 15;
	errstr.buf_addr = errBuf;
	errstr.len_alloc = sizeof(errBuf);
	errstr.len_used = 0;

	printf("\n\nydb_ci_t() tests\n");
	printf("ydb_ci_t() on a properly allocated buffer should return no error\n");
	status = ydb_ci_t(YDB_NOTTP, &errstr, "retStr", &goodStr);
	if(YDB_OK != status){
		printf("FAIL: ydb_ci_t() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci_t() returned YDB_OK\n");
	}
	goodStr.address[20] = '\0'; // null terminate for strcmp()
	if (0 != strcmp(goodStr.address, "a0a1a2a3a4a5a6a7a8a9")){
		printf("FAIL: ydb_ci_t() did not return the correct string. Got: %s; Expected: a0a1a2a3a4a5a6a7a8a9\n", goodStr.address);
	} else {
		printf("PASS: ydb_ci_t() returned the correct string\n");
	}

	printf("\nydb_ci_t() on a improperly (too small) buffer; should return INVSTRLEN\n");
	status = ydb_ci_t(YDB_NOTTP, &errstr, "retStr", &badStr);
	errstr.buf_addr[errstr.len_used] = '\0';
	if(-YDB_ERR_INVSTRLEN != status){
		printf("FAIL: ydb_ci_t() did not return the correct status. Got: %d; Expected: %d\n", status, -YDB_ERR_INVSTRLEN);
	} else {
		printf("PASS: ydb_ci_t() returned INVSTRLEN\n");
	}
	if(0 != strcmp(errBuf, "150375522,(SimpleThreadAPI),%YDB-E-INVSTRLEN, Invalid string length 20: max 15")){
		printf("FAIL: ydb_ci_t() did not return the correct error message. Got: \"%s\"; Expected: "
				"\"150375522,(SimpleThreadAPI),%%YDB-E-INVSTRLEN, Invalid string length 20: max 15\"\n", errBuf);
	} else {
		printf("PASS: ydb_ci_t() returned the correct error message\n");
	}


	printf("\n\nydb_cip_t() tests\n");
	ci_name_descriptor callin;
	callin.rtn_name.address = "retStr";
	callin.rtn_name.length = 6;
	callin.handle = NULL;
	printf("ydb_cip_t() on a properly allocated buffer should return no error\n");
	status = ydb_cip_t(YDB_NOTTP, &errstr, &callin, &goodStr);
	if(YDB_OK != status){
		printf("FAIL: ydb_cip_t() did not return the correct status. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_cip_t() returned YDB_OK\n");
	}
	goodStr.address[20] = '\0'; // null terminate for strcmp()
	if (0 != strcmp(goodStr.address, "a0a1a2a3a4a5a6a7a8a9")){
		printf("FAIL: ydb_cip_t() did not return the correct string. Got: %s; Expected: a0a1a2a3a4a5a6a7a8a9\n", goodStr.address);
	} else {
		printf("PASS: ydb_cip_t() returned the correct string\n");
	}

	printf("\nydb_cip_t() on a improperly (too small) buffer; should return INVSTRLEN\n");
	status = ydb_cip_t(YDB_NOTTP, &errstr, &callin, &badStr);
	errstr.buf_addr[errstr.len_used] = '\0';
	if(-YDB_ERR_INVSTRLEN != status){
		printf("FAIL: ydb_cip_t() did not return the correct status. Got: %d; Expected: %d\n", status, -YDB_ERR_INVSTRLEN);
	} else {
		printf("PASS: ydb_cip_t() returned INVSTRLEN\n");
	}
	if(0 != strcmp(errBuf, "150375522,(SimpleThreadAPI),%YDB-E-INVSTRLEN, Invalid string length 20: max 15")){
		printf("FAIL: ydb_cip_t() did not return the correct error message. Got: \"%s\"; Expected: "
				"\"150375522,(SimpleThreadAPI),%%YDB-E-INVSTRLEN, Invalid string length 20: max 15\"\n", errBuf);
	} else {
		printf("PASS: ydb_cip_t() returned the correct error message\n");
	}
	return 0;
}

int main(int argc, char *argv[]){
	if (argc != 2){
		printf("This only takes one argument; either: sapi|stapi\n");
		return 1;
	}
	if(0 == strcmp(argv[1], "sapi")){
		sapi();
	} else if (0 == strcmp(argv[1], "stapi")){
		stapi();
	} else {
		printf("Invalid argument. enter either: sapi|stapi\n");
		return 1;
	}
	return 0;
}
