/****************************************************************
 *								*
 * Copyright (c) 2019-2026 YottaDB LLC and/or its subsidiaries.	*
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
#include <pthread.h>
#include <unistd.h>
#include <string.h>

#include "libyottadb.h"


#define GLOBAL1 	"^MyGlobal1"
#define GLOBAL2 	"^MyGlobal2"
#define LOCAL1		"MyLocal1xx"
#define LOCAL2		"MyLocal2xx"
#define BASE_LEN	11 //includes \0
#define SUB_LEN		5  //includes \0

/* if the arm toggle isn't set the default to 0 */
#ifndef ISARM
#define ISARM 0
#endif

/* macro returns a random integer between [a,b] */
#define RAND_INT(a, b) rand() % (b - a + 1) + a

/* globals that are randomly assigned at the init of the program
 * as such they are not constants but should be treated as such
 */
int	TEST_TIMEOUT; 	//test time out in seconds
int	DRIVER_THREADS;
int	MAX_THREADS;
int	THREADS_TO_MAKE;
int	MAX_DEPTH;
float	NEST_RATE;	// max depth for nesting

int	is_ydb464_subtest;

/* struct for storing a string array mallocs to one large buffer */
typedef struct strArr {
	char* arr[5];
	int length;
} strArr;

/* test settings struct */
typedef struct testSettings {
	int maxDepth;
	double nestRate;
} testSettings;

/* holds the args for the runProc commands
 * used to pass the parameters to it on threaded calls
 */
struct runProc_args {
	uint64_t tptoken;
	ydb_buffer_t* errstr;
	testSettings* settings;
	int curDepth;
};

/* prototypes */
strArr genGlobalName();
int runProc(uint64_t tptoken, ydb_buffer_t* errstr, testSettings* settings, int curDepth);
int tpHelper(uint64_t tptoken, ydb_buffer_t* errstr, void* tpfnparm);
void* threadHelper(void* args);
void* toggleTimeout(void* args);
void* runProc_driver(void* args);
int storePID();

/* thread globals */
pthread_mutex_t lock;
int curThreads;
int isTimeout;

int main()
{
	srand(time(NULL));
	TEST_TIMEOUT = RAND_INT(15,120);
	/* to prevent a rare failure arm machines make less threads */
	if (ISARM) {
		MAX_THREADS = RAND_INT(2, 10);
		THREADS_TO_MAKE = RAND_INT(0,2);
	} else {
		MAX_THREADS = RAND_INT(4, 50);
		THREADS_TO_MAKE = RAND_INT(0,10);
	}
	DRIVER_THREADS = RAND_INT(2,10);
	MAX_DEPTH = RAND_INT(2, 20);
	NEST_RATE = (float) (RAND_INT(0,20)) / 100;
	is_ydb464_subtest = (!memcmp(getenv("test_subtest_name"), "ydb464", sizeof("ydb464")));
	pthread_t tids[DRIVER_THREADS];
	int status;

	//thread setup
	status = pthread_mutex_init(&lock, NULL);
	if(status != 0)
	{
		printf("Mutex init failed\n");
		return 1;
	}
	curThreads = 0;

	isTimeout = 0;
	pthread_t timeout;
	status = pthread_create(&timeout, NULL, &toggleTimeout, NULL);
	if(status != 0)
	{
		printf("Something went wrong when creating the timeout\n");
		return 1;
	}

	//test driver
	status = ydb_init(); //needed incase an assert fails without having done a ydb call yet
	YDB_ASSERT(status == YDB_OK);
	/* for ydb464 which needs the pid of the process
	 * so store it in a global ^pids
	 */
#ifdef NO_PRINT
	status = storePID();
	YDB_ASSERT(status == YDB_OK);
#endif

	testSettings settings;
	settings.maxDepth = MAX_DEPTH;
	settings.nestRate = NEST_RATE;
	int i;
	for(i = 0; i < DRIVER_THREADS; ++i)
		pthread_create(&tids[i], NULL, &runProc_driver, &settings);

	for(i = 0; i < DRIVER_THREADS; ++i)
		pthread_join(tids[i], NULL);

	pthread_join(timeout, NULL);
	return 0;
}

void *runProc_driver(void *args) {
	int rc;
	testSettings *settings = (testSettings *)args;

	while(!isTimeout)
	{
		rc = runProc((uint64_t) YDB_NOTTP, NULL, settings, 0);
		if (YDB_ERR_CALLINAFTERXIT == rc)
			break;
		else if (YDB_OK != rc)
			printf("runProc_driver: Error rc %d from runProc()\n", rc);
	}
	return (void *)0;
}

/* generates a strArr struct to be turned in to a ydb_buffer_t
 */
strArr genGlobalName(){
	strArr ret;
	int num_subs = rand() % 5;
	int baseId = rand() % 4;

	char* rawbuf = malloc(32 * sizeof(char));
	ret.length = 0;
	switch (baseId) {
		case 0:
			ret.arr[0] = rawbuf;
			strcpy(ret.arr[0], GLOBAL1);
			ret.length++;
			break;
		case 1:
			ret.arr[0] = rawbuf;
			strcpy(ret.arr[0], GLOBAL2);
			ret.length++;
			break;
		case 2:
			ret.arr[0] = rawbuf;
			strcpy(ret.arr[0], LOCAL1);
			ret.length++;
			break;
		case 3:
			ret.arr[0] = rawbuf;
			strcpy(ret.arr[0], LOCAL2);
			ret.length++;
			break;
	}
	int i;
	for(i = 0; i < num_subs; i++){ //append the subscripts
		ret.arr[i + 1] = rawbuf + BASE_LEN + (i * SUB_LEN);
		sprintf(ret.arr[i + 1], "sub%d", i);
		ret.length++;
	}
	return ret;
}

/* performs various SimpleThreadAPI functions based on a random number
 * on exit it spawns more threads until maxDepth is hit
 */
int runProc(uint64_t tptoken, ydb_buffer_t* errstr, testSettings* settings, int curDepth){
	int		status;
	int		shutdown = 0;
	char		errbuf[2048];
	int		remainingOdds = 80 - (100 * settings->nestRate);
	ydb_buffer_t	zstatusBuf, jsonValue;
	YDB_MALLOC_BUFFER(&zstatusBuf, 2048);

	//get a global
	strArr t = genGlobalName();
	ydb_buffer_t basevar, subs[t.length - 1]; // -1 for the basevar
	YDB_MALLOC_BUFFER(&basevar, BASE_LEN);
	YDB_COPY_STRING_TO_BUFFER(t.arr[0], &basevar, status);
	YDB_ASSERT(status);
	int i;
	for(i = 0; i < t.length - 1; i++){
		YDB_MALLOC_BUFFER(&subs[i], SUB_LEN);
		YDB_COPY_STRING_TO_BUFFER(t.arr[i + 1], &subs[i], status);
		YDB_ASSERT(status);
	}
	int action = rand()/(RAND_MAX / 100); //generate random integer [0, 100]
	if (action < 20) { //ydb_set_st() case gets bias towards occurrence
		ydb_buffer_t value;
		YDB_LITERAL_TO_BUFFER("MySecretValue", &value);
		status = ydb_set_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs, &value);
		//there are some error codes we accept; anything other than that, raise an error
		if (status != YDB_OK){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) from ydb_set_st() issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
	} else if (action < 20 + remainingOdds * (2 / 17.0f)) { //ydb_get_st() case
		ydb_buffer_t retvalue;
		YDB_MALLOC_BUFFER(&retvalue, 16);

		status = ydb_get_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs, &retvalue);
		//there are some error codes we accept; anything other than that, raise an error
		if (status != YDB_OK){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) from ydb_get_st() issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
		YDB_FREE_BUFFER(&retvalue);
	} else if (action < 20 + remainingOdds * (3 / 17.0f)) { //ydb_data_st() case
		unsigned int retvalue;

		status = ydb_data_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs, &retvalue);
		//there are some error codes we accept; anything other than that, raise an error
		if (status != YDB_OK){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) from ydb_data_st() issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
		switch (retvalue) {
			case 0:
				break;
			case 1:
				break;
			case 10:
				break;
			case 11:
				break;
			default:
				printf("Unexpected data value issued!");
		}
	} else if (action < 20 + remainingOdds * (4 / 17.0f)){ //ydb_node_next_st() and ydb_node_previous_st() case
		int retnumsubs = 4; //max number of possible subs

		ydb_buffer_t *subsList, retsubs[retnumsubs];
		int i;
		for(i = 0; i < retnumsubs; ++i)
			YDB_MALLOC_BUFFER(&retsubs[i], SUB_LEN);
		int direction = rand();
		if (direction < RAND_MAX / 2){ //50% chance to move forward or backward
			direction = 1;
		} else {
			direction = -1;
		}
		status = YDB_OK;
		int numsubs = t.length-1; //the starting length
		subsList = subs;      //the starting list
		while (status == YDB_OK){ //while not at the end, or received another error
			if (direction == 1)
				status = ydb_node_next_st(tptoken, &zstatusBuf, &basevar, numsubs, subsList, &retnumsubs, retsubs);
			else
				status = ydb_node_previous_st(tptoken, &zstatusBuf, &basevar, numsubs, subsList, &retnumsubs, retsubs);
			numsubs = retnumsubs;
			subsList = retsubs;//set the subsList to the new list
			retnumsubs = 4; //reset the retsubs length
		}
		//there are some error codes we accept; anything other than that, raise an error
		if (status != YDB_ERR_NODEEND){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
		for(i = 0; i < retnumsubs; ++i)
			YDB_FREE_BUFFER(&retsubs[i]);
	} else if (action < 20 + remainingOdds * (5 / 17.0f)){ //ydb_subscript_next_st() and ydb_subscript_previous_st() calls
		ydb_buffer_t retvalue;

		YDB_MALLOC_BUFFER(&retvalue, 16);
		int direction = rand();
		if (direction < RAND_MAX / 2) //50% chance to move forward or backward
			direction = 1;
		else
			direction = -1;
		status = YDB_OK;
		while (status == YDB_OK){ //while not at the end, or received another error
			if (direction == 1) {
				status = ydb_subscript_next_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs, &retvalue);
			} else {
				status = ydb_subscript_previous_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs, &retvalue);
			}
			int done;
			if(t.length == 1){
				YDB_COPY_BUFFER_TO_BUFFER(&retvalue, &basevar, done);
				YDB_ASSERT(done);
			} else {
				YDB_COPY_BUFFER_TO_BUFFER(&retvalue, &subs[t.length-2], done);
				YDB_ASSERT(done);
			}
		}
		//there are some error codes we accept; anything other than that, raise an error
		if (status != YDB_ERR_NODEEND){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
		YDB_FREE_BUFFER(&retvalue);
	} else if (action < 20 + remainingOdds * (6 / 17.0f)){ //ydb_incr_st() case
		int incr_amount = rand() / (RAND_MAX / 5); //rand int [0, 5]
		char incr_str[3];	/* 2 digits to store the 2-digit number + 1 byte for null terminator byte */
		ydb_buffer_t increment, retvalue;

		YDB_MALLOC_BUFFER(&retvalue, 16);
		YDB_MALLOC_BUFFER(&increment, 2);
		sprintf(incr_str, "%d", incr_amount);
		YDB_COPY_STRING_TO_BUFFER(incr_str, &increment, status);
		status = ydb_incr_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs, &increment, &retvalue);
		if (YDB_ERR_CALLINAFTERXIT == status)
			shutdown = 1;
		else if (status != YDB_OK)
		{
			zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
			printf("Unexpected return code (%d) from ydb_incr_st() issued! %s\n", status, zstatusBuf.buf_addr);
		}
		YDB_FREE_BUFFER(&retvalue);
		YDB_FREE_BUFFER(&increment);
	} else if (action < 20 + remainingOdds * (7 / 17.0f)){ //ydb_lock*_st() case
		unsigned long long lockTimeout = 0;

		status = ydb_lock_st(tptoken, &zstatusBuf, lockTimeout, 1, &basevar, t.length-1, subs);
		if (status != YDB_OK){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_TPLOCK:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) from ydb_lock_st() issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
		status = ydb_lock_incr_st(tptoken, &zstatusBuf, lockTimeout, &basevar, t.length - 1, subs);
		if (status != YDB_OK){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_TPLOCK:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) from ydb_lock_incr_st() issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
		status = ydb_lock_decr_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs);
		if (status != YDB_OK){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_TPLOCK:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) from ydb_lock_decr_st() issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
		status = ydb_lock_st(tptoken, &zstatusBuf, lockTimeout, 0);
		if (status != YDB_OK){
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_INVSVN:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_TPLOCK:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) from ydb_lock_st() issued! %s\n", status, zstatusBuf.buf_addr);
			}
		}
	} else if (action < 20 + remainingOdds * (8 / 17.0f)){ //ydb_str2zwr case
		ydb_buffer_t strIn, strOut;
		char* compStr = "\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\"";

		YDB_LITERAL_TO_BUFFER("a\n\tb\0c", &strIn);
		YDB_MALLOC_BUFFER(&strOut, 64);
		status = ydb_str2zwr_st(tptoken, &zstatusBuf, &strIn, &strOut);
		if (YDB_ERR_CALLINAFTERXIT == status)
			shutdown = 1;
		else
		{
			if (status != YDB_OK)
			{
				zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
				printf("Unexpected return code (%d) from ydb_str2zwr() issued! %s\n", status, zstatusBuf.buf_addr);
			}
			strOut.buf_addr[strOut.len_used] = '\0';
			if (0 != strcmp(compStr, strOut.buf_addr))
				printf("ydb_str2zwr did not return the right value\n");
		}
		YDB_FREE_BUFFER(&strOut);
	} else if (action < 20 + remainingOdds * (9 / 17.0f)){ //ydb_zwr2str case
		ydb_buffer_t strIn, strOut;
		char *compStr = "a\n\tb\0c";

		YDB_LITERAL_TO_BUFFER("\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\"", &strIn);
		YDB_MALLOC_BUFFER(&strOut, 64);
		status = ydb_zwr2str_st(tptoken, &zstatusBuf, &strIn, &strOut);
		if (YDB_ERR_CALLINAFTERXIT == status)
			shutdown = 1;
		else
		{
			if (status != YDB_OK)
			{
				zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
				printf("Unexpected return code (%d) from ydb_zwr2str() issued! %s\n", status, zstatusBuf.buf_addr);
			}
			strOut.buf_addr[strOut.len_used] = '\0';
			if (0 != strcmp(compStr, strOut.buf_addr)){
				printf("ydb_zwr2str did not return the right value\n");
			}
		}
		YDB_FREE_BUFFER(&strOut);

	} else if (action < 20 + remainingOdds * (10 / 17.0f) && tptoken != YDB_NOTTP){ //ydb_exit() case, don't call from main thread
		status = ydb_exit();
		if (status != -YDB_ERR_INVYDBEXIT)
		{
			zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
			printf("Unexpected return code (%d) from ydb_exit() issued! %s\n", status, zstatusBuf.buf_addr);
		}
		status = YDB_OK;

	} else if (action < 20 + remainingOdds * (11 / 17.0f)){ //ydb_init() case
		status = ydb_init();
		if(status != YDB_OK){
			zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
			printf("Unexpected return code (%d) from ydb_init() issued! %s\n", status, zstatusBuf.buf_addr);
		}
	} else if (action < 20 + remainingOdds * (12 / 17.0f))
	{	// ydb_message_t() case
		ydb_buffer_t errOut;
		YDB_MALLOC_BUFFER(&errOut, 2048);

		status = ydb_message_t(tptoken, &zstatusBuf, -1, &errOut);
		if (YDB_ERR_CALLINAFTERXIT == status)
			shutdown = 1;
		else
		{
			if (status != YDB_OK)
			{
				zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
				printf("Unexpected return code (%d) from ydb_message_t() issued! %s\n", status,
				       zstatusBuf.buf_addr);
			}
			if (errOut.len_used == 0)
				printf("ydb_message_t() did not correctly modify the buffer\n");
		}
		YDB_FREE_BUFFER(&errOut);
	} else if (action < 20 + remainingOdds * (13 / 17.0f)) //ydb_zstatus() case
		zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';//no check can be done here just ensuring no sig11
	else if (action < 20 + remainingOdds * (14 / 17.0f)){ //ydb_delete_st() case
		int type = rand();
		if (type < RAND_MAX/2)
			status = ydb_delete_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs, YDB_DEL_TREE);
		else
			status = ydb_delete_st(tptoken, &zstatusBuf, &basevar, t.length-1, subs, YDB_DEL_NODE);
		if (YDB_ERR_CALLINAFTERXIT == status)
			shutdown = 1;
		else if (status != YDB_OK)
		{
			zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
			printf("Unexpected return code (%d) from ydb_delete_st() issued! %s\n", status, zstatusBuf.buf_addr);
		}
	} else if (action < 20 + remainingOdds * (15 / 17.0f)){ //ydb_delete_excl_st() case
		if(t.arr[0][0] != '^')
			status = ydb_delete_excl_st(tptoken, &zstatusBuf, 1, &basevar);
		else
			status = YDB_OK;
		if (YDB_ERR_CALLINAFTERXIT == status)
			shutdown = 1;
		else if (status != YDB_OK)
		{
			zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
			printf("Unexpected return code (%d) from ydb_delete_excl_st() issued! %s\n", status, zstatusBuf.buf_addr);
		}

	} else if (action < 20 + remainingOdds * (16 / 17.0f)) { //ydb_encode_st() case
		ydb_buffer_t jsonout;
		int type = rand() % 2;

		if (type)
			memcpy(t.arr[0], "^JsonDataT", BASE_LEN);
		else
			memcpy(t.arr[0], "JsonDataTX", BASE_LEN);
		YDB_COPY_STRING_TO_BUFFER(t.arr[0], &basevar, status);
		YDB_ASSERT(status);
		YDB_MALLOC_BUFFER(&jsonout, 4096); //the M arrays created by ydb_decode_st() can grow, 4096 should be enough
		status = ydb_encode_st(tptoken, &zstatusBuf, &basevar, t.length - 1, subs, "JSON", &jsonout);
		if (status != YDB_OK) {
			switch (status) {
				case YDB_ERR_GVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_LVUNDEF:
					status = YDB_OK;
					break;
				case YDB_ERR_CALLINAFTERXIT:
					shutdown = 1;
					break;
				default:
					zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
					printf("Unexpected return code (%d) from ydb_encode_st() issued! %s\n",
						status, zstatusBuf.buf_addr);
			}
		}
		YDB_FREE_BUFFER(&jsonout);

	} else if (action < 20 + remainingOdds * (17 / 17.0f)) { //ydb_decode_st() case
		int type = rand() % 2;
		char *jsonStr = "{\"\": 15, \"key\": \"value\", \"anotherKey\": \"anotherValue\", "
				"\"array\": [\"one\", 2, null, 2.5, false, -3e2, true, \"\", \"null\"]}";

		YDB_STRING_TO_BUFFER(jsonStr, &jsonValue);
		if (type)
			memcpy(t.arr[0], "^JsonDataT", BASE_LEN);
		else
			memcpy(t.arr[0], "JsonDataTX", BASE_LEN);
		YDB_COPY_STRING_TO_BUFFER(t.arr[0], &basevar, status);
		YDB_ASSERT(status);
		status = ydb_decode_st(tptoken, &zstatusBuf, &basevar, t.length - 1, subs, "JSON", &jsonValue);
		if (YDB_ERR_CALLINAFTERXIT == status)
			shutdown = 1;
		else if (status != YDB_OK) {
			zstatusBuf.buf_addr[zstatusBuf.len_used] = '\0';
			printf("Unexpected return code (%d) from ydb_decode_st() issued! %s\n", status, zstatusBuf.buf_addr);
		}

		/* the last case either does a ydb_tp_st() call
		 * or spawns new threads
		 * if curThreads > MAX_THREADS then it always picks ydb_tp_st()
		 */
	} else if (action <= 100){
		if (curDepth < settings->maxDepth && !isTimeout){
			// if max depth is reached, or the timeout is set, stop creating threads
			ydb_tp2fnptr_t tpfn = &tpHelper;

			struct runProc_args args; //copy the test settings in to the struct
			args.errstr = NULL;
			args.settings = settings;
			args.curDepth = curDepth + 1;
			int choice = rand();
			if (choice < RAND_MAX / 2 || curThreads > MAX_THREADS - THREADS_TO_MAKE){
				// if we are above MAX_THREADS always do ydb_tp_st()
				/* ydb_tp_st() call */
				status = ydb_tp_st(tptoken, &zstatusBuf, tpfn, &args, "BATCH", 0 , NULL);
				if (YDB_ERR_CALLINAFTERXIT == status)
					shutdown = 1;
				else
				{	/* If the "ydb464" subtest is running this program, it is possible a Ctrl-C is received and
					 * handled by one thread which takes the process to exit handling code. It is possible that
					 * exit handling code has already done an "op_trollback()" by the time this thread does its
					 * "ydb_tp_st()" call. That would result in a YDB_ERR_INVTPTRANS error. It is therefore an
					 * expected error. Handle this case in the assert below.
					 */
					YDB_ASSERT((YDB_OK == status) || (is_ydb464_subtest && (YDB_ERR_INVTPTRANS == status)));
				}
			} else {
				/* thread creation */
				pthread_t tid[THREADS_TO_MAKE];
				args.tptoken = tptoken;
				for(i = 0; i < THREADS_TO_MAKE; ++i){
					pthread_mutex_lock(&lock);
					curThreads++; //increment the number of threads on creation
					pthread_mutex_unlock(&lock);
					status = pthread_create(&tid[i], NULL, &threadHelper, &args);
					if(status != 0){
						char strerr[1024];
						strerror_r(status, strerr, sizeof(strerr));
						printf("pthread_create() failed with status: %d, strerror: %s\n", status, strerr);
						printf("Number of threads at this  point: %d\n", curThreads);
						YDB_ASSERT(0); //we want to see a core in this case, so always fail the assert
					}
				}
				for(i = 0; i < THREADS_TO_MAKE; ++i){
					status = pthread_join(tid[i], NULL);
					pthread_mutex_lock(&lock);
					curThreads--; //decrement number of threads after they exit
					pthread_mutex_unlock(&lock);
					if (status != 0){
						char strerr[1024];
						strerror_r(status, strerr, sizeof(strerr));
						printf("pthread_join() failed with status: %d, strerror: %s\n", status, strerr);
						printf("Number of threads at this  point: %d\n", curThreads);
						YDB_ASSERT(0); //we want to see a core in this case, so always fail the assert
					}
				}
			}
		}

	} else {
		printf("Huh, random number out of range (%d)\n", action);
	}

	YDB_FREE_BUFFER(&zstatusBuf);
	YDB_FREE_BUFFER(&basevar);
	for(i = 0; i < t.length-1; ++i)
		YDB_FREE_BUFFER(&subs[i]);
	free(t.arr[0]);		// This is the raw buffer allocated at the top
	return shutdown ? YDB_ERR_CALLINAFTERXIT : 0;
}

/* called by ydb_tp_st()
 * this calls runProc() [0, 19] times
 * these calls only have a 10% chance to nest
 */
int tpHelper(uint64_t tptoken, ydb_buffer_t* errstr, void* tpfnparm){
	int status;
	struct runProc_args* args = (struct runProc_args*) tpfnparm;

	args->tptoken = tptoken; //assign the correct tptoken
	int n = rand() % 20;
	int i;
	for(i = 0; i < n; ++i){
		args->settings->nestRate = 0.1;
		threadHelper(args);
	}
	return 0;
}

/* takes the struct runProc_args as an argument then passes that to runProc()
 * just decomposes the struct to give to runProc()
 */
void* threadHelper(void* args){
	struct runProc_args* toPass = (struct runProc_args*) args;
	YDB_ASSERT(toPass->errstr == NULL);
	runProc(toPass->tptoken, toPass->errstr, toPass->settings, toPass->curDepth);
}

/* wait for TEST_TIMEOUT seconds then set the timeout */
void* toggleTimeout(void* args){
	sleep(TEST_TIMEOUT);
	isTimeout = 1;
}

int storePID(){
	char pidStrA[8], pidStrB[8];
	ydb_buffer_t pidGlobal, pidSubs[2];
	int status;
	/* base global */
	YDB_LITERAL_TO_BUFFER("^pids", &pidGlobal);
	/* get the last subscript set and store it in pidSubs */
	pidSubs[0].buf_addr = pidStrA;
	pidSubs[0].len_alloc = 8;
	pidSubs[0].len_used = 0;
	status = ydb_subscript_previous_st(YDB_NOTTP, NULL, &pidGlobal, 1, pidSubs, &pidSubs[0]);
	YDB_ASSERT(status == YDB_OK);
	/* set the node to the pid of the process */
	pidSubs[1].buf_addr = pidStrB;
	pidSubs[1].len_alloc = 8;
	pidSubs[1].len_used = sprintf(pidSubs[1].buf_addr, "%d", getpid());
	status = ydb_set_st(YDB_NOTTP, NULL, &pidGlobal, 2, pidSubs, &pidSubs[1]);
	return status;
}
