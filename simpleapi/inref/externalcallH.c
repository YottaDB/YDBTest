/****************************************************************
 *								*
 * Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "libyottadb.h"

#define globalVarA 	"^a"
#define globalVarB 	"^b"
#define subA		"subA"
#define subB		"subB"

#define intValue 	"42"
#define strValue 	"qwerty"

#define TIMER_10MS	10000000
#define TIMER_100MS  100000000


#define printff(format, ...) ({\
		printf(format, ## __VA_ARGS__);\
		fflush(stdout);\
		})

#define ARRAYSIZE(arr) sizeof(arr)/sizeof(arr[0]) /* number of elements defined in the array */
#define SLEEP(TIME)						\
{								\
	struct timespec rec, rem;				\
	int ret;						\
	rec.tv_sec = TIME / (int)1E9;				\
	rec.tv_nsec = TIME % (int)1E9;				\
	while ((0 < rec.tv_sec) || (0 < rec.tv_nsec))		\
	{							\
		ret = nanosleep(&rec, &rem);			\
		if (0 != ret)					\
		{						\
			rec.tv_sec = rem.tv_sec;		\
			rec.tv_nsec = rem.tv_nsec;		\
		} else						\
		{						\
			rec.tv_sec = 0;				\
			rec.tv_nsec = 0;			\
		}						\
	}							\
}								\

//globals that get set, and used in multiple tests
void timerHelper();
void* glbPtr;
ydb_fileid_ptr_t fileidA, fileidB;
uintptr_t tabHandle;


/* ydb_set_s inside an external	call
 * also serves to set up the data base for the other functions
 * check for this function is in the mumps code
 * although the set works if the other functions work too
 */
int cSet(){
	ydb_buffer_t basevar, value;
	ydb_buffer_t subscripts1[2];
	ydb_buffer_t subscripts2[1];
	int status;

	/* set ^a=42 */
	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	YDB_LITERAL_TO_BUFFER(intValue, &value);
	status = ydb_set_s(&basevar, 0, NULL, &value);
	YDB_ASSERT(status == YDB_OK);

	/* set ^b="qwerty" */
	YDB_LITERAL_TO_BUFFER(globalVarB, &basevar);
	YDB_LITERAL_TO_BUFFER(strValue, &value);
	status = ydb_set_s(&basevar, 0, NULL, &value);
	YDB_ASSERT(status == YDB_OK);

	/* set ^a("subA","subB")="qwerty") */
	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	YDB_LITERAL_TO_BUFFER(subA, &subscripts1[0]);
	YDB_LITERAL_TO_BUFFER(subB, &subscripts1[1]);
	YDB_LITERAL_TO_BUFFER(strValue, &value);
	status = ydb_set_s(&basevar, 2, subscripts1, &value);
	YDB_ASSERT(status == YDB_OK);

	/* set ^a("subA")=42 */
	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	YDB_LITERAL_TO_BUFFER(subA, &subscripts2[0]);
	YDB_LITERAL_TO_BUFFER(intValue, &value);
	status = ydb_set_s(&basevar, 1, subscripts2, &value);
	YDB_ASSERT(status == YDB_OK);

	/* set ^b="qwerty" */
	YDB_LITERAL_TO_BUFFER(globalVarB, &basevar);
	YDB_LITERAL_TO_BUFFER(strValue, &value);
	status = ydb_set_s(&basevar, 0, NULL, &value);
	YDB_ASSERT(status == YDB_OK);

	return 0;
}

/* ydb_data_s inside an external call
 * calls data on globalVarA ^a
 * should return 11
 */
int cData(){
	ydb_buffer_t basevar;
	int status;
	unsigned int retValue;

	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	status = ydb_data_s(&basevar, 0, NULL, &retValue);
	YDB_ASSERT(status == YDB_OK);

	if (retValue == 11){
		printf("PASS\n");
		return 0;
	} else {
		printf("FAIL\n");
		return 1;
	}
}

/* ydb_get_s inside an external call
 * checks the value at globalVarB ^b
 * should return valueB "qwerty"
 */
int cGet(){
	ydb_buffer_t basevar, outvalue;
	int status;
	char outbuf[64];
	outvalue.buf_addr = &outbuf[0];
	outvalue.len_used = 0;
	outvalue.len_alloc = sizeof(outbuf);

	YDB_LITERAL_TO_BUFFER(globalVarB, &basevar);
	status = ydb_get_s(&basevar, 0, NULL, &outvalue);
	YDB_ASSERT(status == YDB_OK);

	outvalue.buf_addr[outvalue.len_used] = '\0';
	if (strcmp(outvalue.buf_addr, strValue) == 0){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_incr_s inside an external call
 * increments ^a from 42 to 43
 * should return 43
 * also then decrements ^a from 43 to 42
 * no check for this just preserving the value of ^a
 */
int cIncr(){
	ydb_buffer_t basevar, increment, outvalue;
	int status;
	char outbuf[64];
	outvalue.buf_addr = &outbuf[0];
	outvalue.len_used = 0;
	outvalue.len_alloc = sizeof(outbuf);

	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	YDB_LITERAL_TO_BUFFER("1", &increment);
	status = ydb_incr_s(&basevar, 0, NULL, &increment, &outvalue);
	YDB_ASSERT(status == YDB_OK);
	outvalue.buf_addr[outvalue.len_used] = '\0';

	if (strcmp(outvalue.buf_addr, "43") == 0){
		printff("PASS\n");
		YDB_LITERAL_TO_BUFFER("-1", &increment);
		ydb_incr_s(&basevar, 0, NULL, &increment, NULL);
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_node_next_s inside an external call
 * calls on globalVarA ^a
 * should return 1 subscript with the name "subA"
 */
int cNodeNext(){
	ydb_buffer_t basevar, value;
	ydb_buffer_t retSubArray[1];
	int status, retSubsUsed = ARRAYSIZE(retSubArray);
	for(int i = 0; i < retSubsUsed; ++i){
		retSubArray[i].buf_addr = malloc(64 * sizeof(char));
		retSubArray[i].len_used = 0;
		retSubArray[i].len_alloc = sizeof(retSubArray[i].buf_addr);
	}

	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	status = ydb_node_next_s(&basevar, 0, NULL, &retSubsUsed, retSubArray);
	YDB_ASSERT(status == YDB_OK);

	retSubArray[0].buf_addr[retSubArray[0].len_used] = '\0';
	if (retSubsUsed == 1 && strcmp(retSubArray[0].buf_addr, subA) == 0){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_node_previous_s inside an external call
 * calls on globalVarA and [subA, subB] ^a("subA","subB")
 * should return 1 subscript with the name "subA"
 */
int cNodePrev(){
		ydb_buffer_t basevar, value;
		ydb_buffer_t subArray[2], retSubArray[1];
		int status, retSubsUsed = ARRAYSIZE(retSubArray);
		for(int i = 0; i < retSubsUsed; ++i){
			retSubArray[i].buf_addr = malloc(64 * sizeof(char));
			retSubArray[i].len_used = 0;
			retSubArray[i].len_alloc = sizeof(retSubArray[i].buf_addr);
		}

		YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
		YDB_LITERAL_TO_BUFFER(subA, &subArray[0]);
		YDB_LITERAL_TO_BUFFER(subB, &subArray[1]);
		status = ydb_node_previous_s(&basevar, 2, subArray, &retSubsUsed, retSubArray);
		YDB_ASSERT(status == YDB_OK);

		retSubArray[0].buf_addr[retSubArray[0].len_used] = '\0';
		if(retSubsUsed == 1 && strcmp(retSubArray[0].buf_addr, subA) == 0){
			printff("PASS\n");
			return 0;
		} else {
			printff("FAIL\n");
			return 1;
		}
}

/* ydb_str2zwr inside an external call
 * calls on "a\n\tb\0c"
 * should return the compStr
 */
int cStr2zwr(){
	ydb_buffer_t strIn, strOut;
	int status;
	char* compStr = "\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\"";
	char outbuf[64];
	strOut.buf_addr = &outbuf[0];
	strOut.len_used = 0;
	strOut.len_alloc = sizeof(outbuf);

	YDB_LITERAL_TO_BUFFER("a\n\tb\0c", &strIn);
	status = ydb_str2zwr_s(&strIn, &strOut);
	YDB_ASSERT(status == YDB_OK);

	strOut.buf_addr[strOut.len_used] = '\0';
	if (strcmp(strOut.buf_addr, compStr) == 0){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		printff("%s\n", strOut.buf_addr);
		return 1;
	}
}

/* ydb_zwr2str_s inside an external call
 * calls on "\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\"_$C(0)"
 * should return compStr
 */
int cZwr2str(){
	ydb_buffer_t strIn, strOut;
	int status;
	char* compStr = "a\n\tb\0c";
	char outbuf[64];
	strOut.buf_addr = &outbuf[0];
	strOut.len_used = 0;
	strOut.len_alloc = sizeof(outbuf);

	YDB_LITERAL_TO_BUFFER("\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\"_$C(0)", &strIn);
	status = ydb_zwr2str_s(&strIn, &strOut);
	YDB_ASSERT(status == YDB_OK);

	strOut.buf_addr[strOut.len_used] = '\0';
	if (strcmp(strOut.buf_addr, compStr) == 0){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		printf("%s\n", strOut.buf_addr);
		return 1;
	}
}

/* ydb_subscript_next_s inside an external call
 * calls on globalVarA ^a
 * should return globalVarB ^b
 */
int cSubNext(){
	ydb_buffer_t basevar, retValue;
	char outbuf[64];
	int status;
	retValue.buf_addr = &outbuf[0];
	retValue.len_used = 0;
	retValue.len_alloc = sizeof(outbuf);

	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	status = ydb_subscript_next_s(&basevar, 0, NULL, &retValue);
	YDB_ASSERT(status == YDB_OK);

	retValue.buf_addr[retValue.len_used] = '\0';
	if(strcmp(retValue.buf_addr, globalVarB) == 0){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_subscript_previous_s inside an external call
 * calls on globalVarB ^b
 * should return globalVarA ^a
 */
int cSubPrev(){
	ydb_buffer_t basevar, retValue;
	char outbuf[64];
	int status;
	retValue.buf_addr = &outbuf[0];
	retValue.len_used = 0;
	retValue.len_alloc = sizeof(outbuf);

	YDB_LITERAL_TO_BUFFER(globalVarB, &basevar);
	status = ydb_subscript_previous_s(&basevar, 0, NULL, &retValue);
	YDB_ASSERT(status == YDB_OK);

	retValue.buf_addr[retValue.len_used] = '\0';
	if(strcmp(retValue.buf_addr, globalVarA) == 0){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_delete_s inside an external call
 * calls on globalVarA ^a
 * deletes the node
 * then checks using get that it is gone
 * also recalls cSet to restore the database
 * the get should return YDB_ERR_GVUNDEF
 */
int cDelete(){
	ydb_buffer_t basevar, retValue;
	int status;
	char outbuf[64];
	retValue.buf_addr = &outbuf[0];
	retValue.len_used = 0;
	retValue.len_alloc = sizeof(outbuf);

	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	status = ydb_delete_s(&basevar, 0, NULL, YDB_DEL_NODE);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_get_s(&basevar, 0, NULL, &retValue);
	if(status == YDB_ERR_GVUNDEF){
		printff("PASS\n");
		cSet();
		return 0;
	} else {
		printff("FAIL\n");
		cSet();
		return 1;
	}
}

/* ydb_delete_excl_s inside an external call
 * deletes a localVar "local"
 * that was set in the M helper function
 * checks with ydb_get_s
 * which should return YDB_ERR_LVUNDEF
 */
int cDeleteExcl(){
	ydb_buffer_t basevar, retValue;
	int status;
	char outbuf[64];
	retValue.buf_addr = &outbuf[0];
	retValue.len_used = 0;
	retValue.len_alloc = sizeof(outbuf);

	YDB_LITERAL_TO_BUFFER("local", &basevar);
	status = ydb_delete_excl_s(0, NULL);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_get_s(&basevar, 0, NULL, &retValue);
	if(status == YDB_ERR_LVUNDEF){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_tp_s inside an external call
 * calls on cSet
 * should return YDB_OK
 */
int cTp(){
	ydb_tpfnptr_t tfpn;
	int status;

	tfpn = &cSet;
	status = ydb_tp_s(tfpn, NULL, "ID", 0, NULL);
	YDB_ASSERT(status == YDB_OK);
	printff("PASS\n");
	return 0;
}

/* ydb_lock_s inside an external call
 * prints the list of locks after the call
 * releases all locks on exit
 * no check in the test
 * will just be compared to the diff file
 */
int cLock(){
	unsigned long long timeout = 0;
	ydb_buffer_t basevar;
	int status;

	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	status = ydb_lock_s(timeout, 1, &basevar, 0, NULL);
	YDB_ASSERT(status == YDB_OK);
	printff("\n\nList of locks...");
	system("$ydb_dist/lke show -all -wait");
	status = ydb_lock_s(timeout, 0);
	YDB_ASSERT(status == YDB_OK);
	printff("Release of locks...\n");
	system("$ydb_dist/lke show -all -wait");
	printff("PASS\n\n");
	return 0;
}

/* ydb_lock_incr_s inside an external call
 * prints the list of locks after the call
 * no check in the test
 * will just be compared to the diff file
 * leaves lock in place for use with the decr function
 */
int cLockIncr(){
	   unsigned long long timeout = 0;
	   ydb_buffer_t basevar;
	   int status;

	   YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	   status = ydb_lock_incr_s(timeout, &basevar, 0, NULL);
	   YDB_ASSERT(status == YDB_OK);
	   printff("\nList of locks...");
	   system("$ydb_dist/lke show -all -wait");
	   printff("PASS\n\n");
	   return 0;
}

/* ydb_lock_decr_s inside an external call
 * prints the list of locks after the call
 * no check in the test
 * will just be compared to the diff file
 * decrements on the lock left by the incr function
 */
int cLockDecr(){
	ydb_buffer_t basevar;
	int status;

	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	status = ydb_lock_decr_s(&basevar, 0, NULL);
	YDB_ASSERT(status == YDB_OK);
	printff("\nList of locks...\n");
	system("$ydb_dist/lke show -all -wait");
	printff("PASS\n\n");
	return 0;
}

/* ydb_file_name_to_id functions inside an external call
 * creates two fileids and saves them to globals
 * should change the value of fileidA
 */
int cFileid(){
	ydb_string_t filenameA, filenameB;
	ydb_fileid_ptr_t fileidCmp = fileidA;
	int status;

	/* using /proc/swaps and /proc/cpuinfo
	 * since those are 2 files you can reliably
	 * expect to find on any system
	 */
	filenameA.address = "/proc/swaps";
	filenameA.length = sizeof(filenameA.address) - 1;
	filenameB.address = "/proc/cpuinfo";
	filenameB.length = sizeof(filenameB.address) - 1;

	status = ydb_file_name_to_id(&filenameA, &fileidA);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_file_name_to_id(&filenameB, &fileidB);
	YDB_ASSERT(status == YDB_OK);

	if(fileidCmp != fileidA){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
	}
}

/* ydb_file_is_identical inside an external call
 * checks that fileidA and fileidB are identical (they are not)
 * should return YDB_NOTOK
 */
int cFileIdent(){
	int status;
	status = ydb_file_is_identical(fileidA, fileidB);
	YDB_ASSERT(status == YDB_OK || status == YDB_NOTOK);
	if(status == YDB_NOTOK){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_file_id_free inside an external call
 * only check here is that it returns YDB_OK
 */
int cFileFree(){
	int status;
	status = ydb_file_id_free(fileidA);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_file_id_free(fileidB);
	YDB_ASSERT(status == YDB_OK);

	printff("PASS\n");
	return 0;
}

/* ydb_fork_n_core inside an external call
 * dumps a core file
 * needs a check for if the core file exists
 * but to be added later
 */
int cFNC(){
	ydb_fork_n_core();
}

/* ydb_hiber_start inside an external call
 * halts the thread for 0.01 seconds
 * just checks the return status
 * should return YDB_OK
 */
int cHiber(){
	int status;

	status = ydb_hiber_start(TIMER_10MS);
	YDB_ASSERT(status == YDB_OK);
	printff("PASS\n");
	return 0;
}

/* ydb_hiber_start_wait_any inside an external call
 * halts the thread for 0.01 seconds
 * just checks the return status
 * should return YDB_OK
 */
int cHiberW(){
	int status;

	status = ydb_hiber_start_wait_any(TIMER_10MS);
	YDB_ASSERT(status == YDB_OK);
	printff("PASS\n");
	return 0;
}

/* ydb_malloc inside an external call
 * initializes 2 pointers to the same place
 * calls ydb_malloc on one
 * checks to ensure they are different
 */
int cMal(){
	size_t size = 64;
	void *ptrCmp = glbPtr;
	glbPtr = ydb_malloc(size);
	if(glbPtr == ptrCmp || glbPtr == NULL){
		printff("FAIL\n");
		return 1;
	} else {
		printff("PASS\n");
		return 0;
	}
}

/* ydb_free inside an external call
 * cannot really check except for a crash
 */
int cFree(){
	ydb_free(glbPtr);
	printff("PASS\n");
}

/* ydb_message inside an external call
 * checks error message -1
 * then checks if the buffer has been modified
 * should change the value of errmsg.buf_used
 */
int cMsg(){
	ydb_buffer_t errmsg;
	char outbuf[64];
	int status;
	errmsg.buf_addr = &outbuf[0];
	errmsg.len_used = 0;
	errmsg.len_alloc = sizeof(outbuf);

	status = ydb_message(-1, &errmsg);
	YDB_ASSERT(status == YDB_OK);
	if(errmsg.len_used != 0){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_thread_is_main inside an external call
 * should return YDB_OK
 * since this is the main thread
 */
int cMT(){
	int status;

	status = ydb_thread_is_main();
	if(status == YDB_OK){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_timer_start inside an external call
 * sets a timer for 0.01 seconds
 * then the main thread waits for 0.1 seconds
 * should trigger the helper function
 * which will show in the output
 * also leaves another timer running to be canceled int cTimerC
 */
int cTimerS(){
	int timerId = 1, timerIdToCancel = 2, stime = time(NULL);
	int status;

	status = ydb_timer_start(timerId, TIMER_10MS, &timerHelper, sizeof(&stime), &stime);
	YDB_ASSERT(status == YDB_OK);

	SLEEP(TIMER_100MS); //wait for the timer to trip

	status = ydb_timer_start(timerIdToCancel, TIMER_10MS, &timerHelper, sizeof(&stime), &stime);
	YDB_ASSERT(status == YDB_OK);
	return 0;
}

/* ydb_timer_cancel inside an external call
 * cancels a timer set in the cTimerS
 * then the main thread waits for 0.1 seconds
 * should *NOT* see a print statement in the output
 */
int cTimerC(){
	int timerIdToCancel = 2;

	ydb_timer_cancel(timerIdToCancel);
	printff("\n");

	/* since ydb_timer_cancel does not return a status confirming it worked properly
	 * this waits until the timer would have triggered if not canceled
	 * which will print to the log and cause a test failure
	 */
	SLEEP(TIMER_100MS);
	return 0;
}

/* helper function for the timers */
void timerHelper(){
	printff("timer triggered\n");
}

/* ydb_exit inside an external call
 * this call should do nothing
 * and return -YDB_ERR_INVYDBEXIT
 * after that check that set still works
 */
int cExit(){
	ydb_buffer_t basevar, value;
	int status;

	YDB_LITERAL_TO_BUFFER(globalVarA, &basevar);
	YDB_LITERAL_TO_BUFFER(intValue, &value);
	status = ydb_exit();
	if(status != -YDB_ERR_INVYDBEXIT){
		printff("FAIL\n");
		return 1;
	}

	status = ydb_set_s(&basevar, 0, NULL, &value);
	YDB_ASSERT(status == YDB_OK);
	printff("PASS\n");
	return 0;
}

/* ydb_ci inside an external call
 * this calls a helper m function
 * which prints to stdout
 * then checks status
 */
int cCi(){
	int status;
	status = ydb_ci("mCiHelper");
	YDB_ASSERT(status == YDB_OK);
	return 0;
}

/* ydb_cip inside an external call
 * this calls a helper m function
 * which prints to stdout
 * then checks status
 */
int cCip(){
	ci_name_descriptor mFunc;
	ydb_string_t funcName;
	int status;

	funcName.address = "mCiHelper";
	funcName.length = sizeof(funcName.address) - 1;
	mFunc.rtn_name = funcName;
	mFunc.handle = NULL;
	status = ydb_cip(&mFunc);
	YDB_ASSERT(status == YDB_OK);
	return 0;
}

/* ydb_ci_tab_open inside an external call
 * this creates a pointer to a second tab file
 * and checks that the pointer changes
 */
int cCiTab(){
	char* fName = "externalcallSwtich.tab";
	uintptr_t handleCmp = tabHandle;
	int status;

	status = ydb_ci_tab_open(fName, &tabHandle);
	YDB_ASSERT(status == YDB_OK);
	if(tabHandle != handleCmp){
		printff("PASS\n");
		return 0;
	} else {
		printff("FAIL\n");
		return 1;
	}
}

/* ydb_ci_tab_switch inside an external call
 * this switches to a new tab and calls a function from it
 * it then switches back to the main tabfile
 */
int cCiSwitch(){
	uintptr_t oldTab;
	int status;

	status = ydb_ci_tab_switch(tabHandle, &oldTab);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_ci("mSwitchHelper");
	YDB_ASSERT(status == YDB_OK);

	status = ydb_ci_tab_switch(oldTab, &tabHandle);
	return 0;
}
