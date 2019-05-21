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

#define MAX_THREADS 	50
#define THREADS_TO_MAKE	10
#define TEST_TIMEOUT	120 //test time out in seconds
#define DRIVER_THREADS	8

#define MAX_DEPTH	10  //max depth for nesting
#define NEST_RATE	0.20

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

/* thread globals */
pthread_t tids[DRIVER_THREADS];
pthread_mutex_t lock;
int curThreads;
int isTimeout;

int main(){
	srand(time(NULL));
	int status;

	//thread setup
	status = pthread_mutex_init(&lock, NULL);
	if(status != 0){
		printf("Mutex init failed\n");
		return 1;
	}
	curThreads = 0;

	isTimeout = 0;
	pthread_t timeout;
	status = pthread_create(&timeout, NULL, &toggleTimeout, NULL);
	if(status != 0){
		printf("Something went wrong when creating the timeout\n");
		return 1;
	}

	//test driver
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

void* runProc_driver(void* args){
	testSettings* settings = (testSettings* ) args;
	while(!isTimeout){
		runProc((uint64_t) YDB_NOTTP, NULL, settings, 0);
	}
	return 0;
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
	int status;
	char errbuf[2048];
	int remainingOdds = 80 - (100 * settings->nestRate);

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

	if (action < 20) { //ydb_set_st() case gets bias towards occurance
		ydb_buffer_t value;
		YDB_LITERAL_TO_BUFFER("MySecretValue", &value);

		status = ydb_set_st(tptoken, errstr, &basevar, t.length-1, subs, &value);
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) from ydb_set_st() issued! %s\n", status, errbuf);
			}
		}

	} else if (action < 20 + remainingOdds * (2 / 15.0f)) { //ydb_get_st() case
		ydb_buffer_t retvalue;
		YDB_MALLOC_BUFFER(&retvalue, 16);

		status = ydb_get_st(tptoken, errstr, &basevar, t.length-1, subs, &retvalue);
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) from ydb_get_st() issued! %s\n", status, errbuf);
			}
		}
		YDB_FREE_BUFFER(&retvalue);


	} else if (action < 20 + remainingOdds * (3 / 15.0f)) { //ydb_data_st() case
		unsigned int retvalue;

		status = ydb_data_st(tptoken, errstr, &basevar, t.length-1, subs, &retvalue);
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) from ydb_data_st() issued! %s\n", status, errbuf);
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

	} else if (action < 20 + remainingOdds * (4 / 15.0f)){ //ydb_node_next_st() and ydb_node_previous_st() case
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
			if (direction == 1){
				status = ydb_node_next_st(tptoken, errstr, &basevar, numsubs, subsList, &retnumsubs, retsubs);
			} else {
				status = ydb_node_previous_st(tptoken, errstr, &basevar, numsubs, subsList, &retnumsubs, retsubs);
			}
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued! %s\n", status, errbuf);
			}
		}
		for(i = 0; i < retnumsubs; ++i)
		       YDB_FREE_BUFFER(&retsubs[i]);

	} else if (action < 20 + remainingOdds * (5 / 15.0f)){ //ydb_subscript_next_st() and ydb_subscript_previous_st() calls
		ydb_buffer_t retvalue;
		YDB_MALLOC_BUFFER(&retvalue, 16);

		int direction = rand();
		if (direction < RAND_MAX / 2){ //50% chance to move forward or backward
			direction = 1;
		} else {
			direction = -1;
		}

		status = YDB_OK;
		while (status == YDB_OK){ //while not at the end, or received another error
			if (direction == 1) {
				status = ydb_subscript_next_st(tptoken, errstr, &basevar, t.length-1, subs, &retvalue);
			} else {
				status = ydb_subscript_previous_st(tptoken, errstr, &basevar, t.length-1, subs, &retvalue);
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued! %s\n", status, errbuf);
			}
		}
		YDB_FREE_BUFFER(&retvalue);

	} else if (action < 20 + remainingOdds * (6 / 15.0f)){ //ydb_incr_st() case
		int incr_amount = rand() / (RAND_MAX / 5); //rand int [0, 5]
		char incr_str[2];
		ydb_buffer_t increment, retvalue;
		YDB_MALLOC_BUFFER(&retvalue, 16);
		YDB_MALLOC_BUFFER(&increment, 2);

		sprintf(incr_str, "%d", incr_amount);
		YDB_COPY_STRING_TO_BUFFER(incr_str, &increment, status);

		status = ydb_incr_st(tptoken, errstr, &basevar, t.length-1, subs, &increment, &retvalue);
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) from ydb_incr_st() issued! %s\n", status, errbuf);
		}
		YDB_FREE_BUFFER(&retvalue);
		YDB_FREE_BUFFER(&increment);

	} else if (action < 20 + remainingOdds * (7 / 15.0f)){ //ydb_lock*_st() case
		unsigned long long lockTimeout = 0;

		status = ydb_lock_st(tptoken, errstr, lockTimeout, 1, &basevar, t.length-1, subs);
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) from ydb_lock_st() issued! %s\n", status, errbuf);
			}
		}
		status = ydb_lock_incr_st(tptoken, errstr, lockTimeout, &basevar, t.length-1, subs);
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) from ydb_lock_incr_st() issued! %s\n", status, errbuf);
			}
		}
		status = ydb_lock_decr_st(tptoken, errstr, &basevar, t.length-1, subs);
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) from ydb_lock_decr_st() issued! %s\n", status, errbuf);
			}
		}
		status = ydb_lock_st(tptoken, errstr, lockTimeout, 0);
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
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) from ydb_lock_st() issued! %s\n", status, errbuf);
			}
		}

	} else if (action < 20 + remainingOdds * (8 / 15.0f)){ //ydb_str2zwr case
		ydb_buffer_t strIn, strOut;
		char* compStr = "\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\"";


		YDB_LITERAL_TO_BUFFER("a\n\tb\0c", &strIn);
		YDB_MALLOC_BUFFER(&strOut, 64);
		status = ydb_str2zwr_st(tptoken, errstr, &strIn, &strOut);
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) from ydb_str2zwr() issued! %s\n", status, errbuf);
		}
		strOut.buf_addr[strOut.len_used] = '\0';
		if (0 != strcmp(compStr, strOut.buf_addr)){
			printf("ydb_str2zwr did not return the right value\n");
		}
		YDB_FREE_BUFFER(&strOut);

	} else if (action < 20 + remainingOdds * (9 / 15.0f)){ //ydb_zwr2str case
		ydb_buffer_t strIn, strOut;
		char* compStr = "a\n\tb\0c";


		YDB_LITERAL_TO_BUFFER("\"a\"_$C(10,9)_\"b\"_$C(0)_\"c\"", &strIn);
		YDB_MALLOC_BUFFER(&strOut, 64);
		status = ydb_zwr2str_st(tptoken, errstr, &strIn, &strOut);
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) from ydb_zwr2str() issued! %s\n", status, errbuf);
		}
		strOut.buf_addr[strOut.len_used] = '\0';
		if (0 != strcmp(compStr, strOut.buf_addr)){
			printf("ydb_zwr2str did not return the right value\n");
		}
		YDB_FREE_BUFFER(&strOut);

	} else if (action < 20 + remainingOdds * (10 / 15.0f) && tptoken != YDB_NOTTP){ //ydb_exit() case, don't call from main thread
		status = ydb_exit();
		if(status != -YDB_ERR_INVYDBEXIT){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) from ydb_exit() issued! %s\n", status, errbuf);
		}
		status = YDB_OK;

	} else if (action < 20 + remainingOdds * (11 / 15.0f)){ //ydb_init() case
		status = ydb_init();
		if(status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) from ydb_init() issued! %s\n", status, errbuf);
		}

	}else if (action < 20 + remainingOdds * (12 / 15.0f)){ //ydb_message_t() case
		ydb_buffer_t errOut;
		YDB_MALLOC_BUFFER(&errOut, 2048);

		status = ydb_message_t(tptoken, errstr, -1, &errOut);
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) from ydb_message_t() issued! %s\n", status, errbuf);
		}
		if (errOut.len_used == 0){
			printf("ydb_message_t() did not correctly modify the buffer\n");
		}
		YDB_FREE_BUFFER(&errOut);
	} else if (action < 20 + remainingOdds * (13 / 15.0f)){ //ydb_zstatus() case
		ydb_zstatus(errbuf, sizeof(errbuf));//no check can be done here just ensuring no sig11

	}else if (action < 20 + remainingOdds * (14 / 15.0f)){ //ydb_delete_st() case
		int type = rand();
		if (type < RAND_MAX/2){
			status = ydb_delete_st(tptoken, errstr, &basevar, t.length-1, subs, YDB_DEL_TREE);
		} else {
			status = ydb_delete_st(tptoken, errstr, &basevar, t.length-1, subs, YDB_DEL_NODE);
		}
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) from ydb_delete_st() issued! %s\n", status, errbuf);
		}

	} else if (action < 20 + remainingOdds * (15 / 15.0f)){ //ydb_delete_excl_st() case
		if(t.arr[0][0] != '^'){
			status = ydb_delete_excl_st(tptoken, errstr, 1, &basevar);
		} else {
			status = YDB_OK;
		}
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) from ydb_delete_excl_st() issued! %s\n", status, errbuf);
		}

	/* the last case either does a ydb_tp_st() call
	 * or spawns new threads
	 * if curThreads > MAX_THREADS then it always picks ydb_tp_st()
	 */
	} else if (action <= 100){
		if (curDepth < settings->maxDepth && !isTimeout){ //if max depth is reached, or the timeout is set, stop creating threads
			ydb_tp2fnptr_t tpfn = &tpHelper;

			struct runProc_args args; //copy the test settings in to the struct
			args.errstr = errstr;
			args.settings = settings;
			args.curDepth = curDepth + 1;
			int choice = rand();
			if (choice < RAND_MAX / 2 || curThreads > MAX_THREADS - THREADS_TO_MAKE){ //if we are above MAX_THREADS always do ydb_tp_st()
				/* ydb_tp_st() call */
				status = ydb_tp_st(tptoken, errstr, tpfn, &args, "BATCH", 0 , NULL);
				YDB_ASSERT(status == YDB_OK);
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
						YDB_ASSERT(0); //we want to see a core in this case, so always fail the assert
					}
				}
			}
		}

	} else {
		printf("Huh, random number out of range (%d)\n", action);
	}

	YDB_FREE_BUFFER(&basevar);
	for(i = 0; i < t.length-1; ++i)
		YDB_FREE_BUFFER(&subs[i]);
	free(t.arr[0]);//this is the raw buffer allocated at the top
	return 0;
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
