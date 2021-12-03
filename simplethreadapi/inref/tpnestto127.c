/****************************************************************
 *								*
 * Copyright (c) 2019-2021 YottaDB LLC and/or its subsidiaries.	*
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

#define getTLevel(tptoken, errstr)({\
		int tStatus;\
		tLevel.len_used = 0;\
		tStatus = ydb_get_st(tptoken, errstr, &dollarTLEVEL, 0, NULL, &tLevel);\
		YDB_ASSERT(tStatus == YDB_OK);\
		tLevel.buf_addr[tLevel.len_used] = '\0';\
		})

int tpNest();

#define	BUFF_LEN 6 /* Space needed to hold "^aNNN" (where NNN is an integer from 1 to 126) and 1 byte for NULL terminator */

char errbuf[2048];
char buf[BUFF_LEN];
int status;

ydb_tp2fnptr_t tpfn;
ydb_buffer_t dollarTLEVEL;
ydb_buffer_t tLevel;


/* calls ydb_tp_st() on a function which nests until TPTOODEEP ($TLEVEL 127)
 * then checks to ensure that all the transactions up to that point still finish
 */
int main(){
	YDB_LITERAL_TO_BUFFER("$TLEVEL", &dollarTLEVEL);
	YDB_MALLOC_BUFFER(&tLevel, 4);

	ydb_buffer_t basevar, outvalue;
	YDB_MALLOC_BUFFER(&outvalue, BUFF_LEN);
	YDB_MALLOC_BUFFER(&basevar, BUFF_LEN);

	tpfn = &tpNest;

	/* check initial $TLEVEL */
	getTLevel(YDB_NOTTP, NULL);
	if(strcmp(tLevel.buf_addr, "0") == 0){
		printf("$TLEVEL is correctly starting at 0\n");
	} else {
		printf("$TLEVEL is not starting at 0 as expected\nStarting at %s\n", tLevel.buf_addr);
		return 1;
	}

	/* check ydb_tp_st() status */
	printf("Starting nest until TPTOODEEP and setting\n");
	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, NULL, 0, NULL);
	if(status == YDB_OK){
		printf("ydb_tp_st() nest returned YDB_OK as expected\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_tp_st() nest did not return YDB_OK as expected\nError message: %s\n", errbuf);
		return 1;
	}

	/* check that $TLEVEL reset to 0 */
	getTLevel(YDB_NOTTP, NULL);
	if(strcmp(tLevel.buf_addr, "0") == 0){
		printf("$TLEVEL returned to 0 as expected\n");
	} else {
		printf("$TLEVEL did not return to 0 as expected\nReturned to %s\n", tLevel.buf_addr);
		return 1;
	}

	/* check that the globalVars was set properly */
	int i;
	for(i = 1; i <= 126; ++i){
		sprintf(buf, "^a%d", i);
		YDB_COPY_STRING_TO_BUFFER(buf, &basevar, status);
		status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &outvalue);
		outvalue.buf_addr[outvalue.len_used] = '\0';
		if(status == YDB_OK && strcmp(buf, outvalue.buf_addr) == 0){
			printf("ydb_get_st() for $TLEVEL %d returned YDB_OK and value was correct as expected\n", i);
		} else {
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("ydb_get_st() for $TLEVEL %d did not return YDB_OK as expected\nError message: %s\n", i, errbuf);
			return 1;
		}
	}

	printf("TP nest till TPTOODEEP correctly completes transactions\n");
	return 0;
}

/* recursively calls ydb_tp_st() until TPTOODEEP ($TLEVEL 127)
 * then attempts to set a globalVar at every $TLEVEL
 */
int tpNest(uint64_t tptoken, ydb_buffer_t* errstr){
	getTLevel(tptoken, errstr);
	printf("$TLEVEL is %s\n", tLevel.buf_addr);
	fflush(stdout);
	status = ydb_tp_st(tptoken, errstr, tpfn, NULL, NULL, 0, NULL);
	if(status == YDB_ERR_TPTOODEEP)
		printf("Returned YDB_ERR_TPTOODEEP\nPerforming sets now\n");

	ydb_buffer_t basevar;

	getTLevel(tptoken, errstr);
	YDB_MALLOC_BUFFER(&basevar, BUFF_LEN);
	sprintf(buf, "^a%s", tLevel.buf_addr); //prepend ^a to $TLEVEL to use as a global
	YDB_COPY_STRING_TO_BUFFER(buf, &basevar, status);
	status = ydb_set_st(tptoken, errstr, &basevar, 0, NULL, &basevar);
	YDB_ASSERT(status == YDB_OK);
	YDB_FREE_BUFFER(&basevar);
	return status;
}
