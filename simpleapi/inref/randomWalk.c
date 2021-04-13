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
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/wait.h>
#include <errno.h>
#include <time.h>
#include <fcntl.h>

#include <string.h>
#include "libyottadb.h"

#define GLOBAL1 	"^MyGlobal1"
#define GLOBAL2 	"^MyGlobal2"
#define LOCAL1		"MyLocal1xx"
#define LOCAL2		"MyLocal2xx"
#define BASE_LEN	11 //includes \0
#define SUB_LEN		5  //includes \0

/* macro returns a random integer between [a,b] */
#define RAND_INT(a, b) rand() % (b - a + 1) + a

/* globals that are randomly assigned at the init of the program
 * as such they are not constants but should be treated as such
 */
int TEST_TIMEOUT; 	// test time out in seconds
int DRIVER_THREADS;
int MAX_DEPTH;		// max depth alowed for tp nesting
float TP_NEST_RATE;

/* struct for storing a string array mallocs to one large buffer */
typedef struct strArr {
	char* arr[5];
	int length;
} strArr;

/* test settings struct */
typedef struct testSettings {
	int maxDepth;
	double nestedTpRate;
} testSettings;

/* holds the args for the runProc commands
 * used to pass the parameters to it on threaded calls
 */
struct runProc_args {
	testSettings* settings;
	int curDepth;
};

/* prototypes */
strArr genGlobalName();
int runProc(testSettings* settings, int curDepth);
int tpHelper(void* tpfnparm);
int runProc_driver(testSettings *args);
void logprint(char *prefix, strArr *var, char *suffix);
int storePID(void);

/* process globals */
time_t startTime;
FILE *logfile;

int main(){
	startTime = time(NULL);
	srand(startTime);
	TEST_TIMEOUT = RAND_INT(15,120);
	DRIVER_THREADS = RAND_INT(2,10);
	MAX_DEPTH = RAND_INT(2, 20);
	TP_NEST_RATE = (float) (RAND_INT(0,20)) / 100;
	int status;

	//test driver
	pid_t childProcess;
	testSettings settings;
	settings.maxDepth = MAX_DEPTH;
	settings.nestedTpRate = TP_NEST_RATE;
	int i;
	for(i = 0; i < DRIVER_THREADS; ++i){
		childProcess = fork();
		if (childProcess == 0){
			return runProc_driver(&settings);
		}
	}
	status = 0;
	/* wait for all child processes to die
	 * have to check for EINTR from yottadb
	 * other wise the parent will exit early
	 */
	while(1){
		if ((i = wait(&status)) == -1){
			if (errno == EINTR) continue;
			break;
		}
	}

	return 0;
}

int runProc_driver(testSettings *settings){
	srand(getpid());
	char filename[16];
	int status;
	sprintf(filename, "pid%d.log", getpid());

	/* for ydb464 which uses this source code we redirect all logging to /dev/null
 	* since it is unimportant and clutters the test directory with log files
	* we also want to change the stdout/stderr redirect to a unique file to avoid clobber
 	*/
#ifndef NO_PRINT
	logfile = fopen(filename, "w");
#else
	status = storePID();
	YDB_ASSERT(status == YDB_OK);
	logfile = fopen("/dev/null", "w");
	char redirectName[16];
	sprintf(redirectName, "child%d.log", getpid());
	int redirect = open(redirectName, O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);
	status = dup2(redirect, STDOUT_FILENO);
	YDB_ASSERT(STDOUT_FILENO == status);
	status = dup2(redirect, STDERR_FILENO);
	YDB_ASSERT(STDERR_FILENO == status);
#endif
	/* estimation of test run time
	 * under estimates in order to ensure TEST_TIMEOUT runtime
	 */
	int i, estimateMult = 0;
	time_t estimate = 0;
	/* we want at least 5 seconds of runtime prior to
	 * estimate to ensure an accurate calcualtion
	 */
	while (estimate < 5){
		for(i = 0; i < 100000; i++){
			runProc(settings, 0);
		}
		estimate = time(NULL) - startTime;
		estimateMult++;
	}
	int estimateRuns = 100000 * estimateMult * (TEST_TIMEOUT / estimate) * 0.90;
	for(i = 0; i < estimateRuns; i++){
		runProc(settings, 0);
	}

	while(time(NULL) - startTime < TEST_TIMEOUT){
		runProc(settings, 0);
	}
	status = fclose(logfile);
	YDB_ASSERT(0 == status);
#ifdef NO_PRINT
	status = close(redirect);
	YDB_ASSERT(0 == status);
#endif
	return 0;
}

/* generates a strArr struct to be turned in to a ydb_buffer_t
 */
strArr genGlobalName(){
	strArr ret;
	int num_subs = rand()%5;
	int baseId = rand() % 4;

	char* rawbuf = malloc(32 * sizeof(char));
	ret.arr[0] = rawbuf;
	int i;
	for(i = 0; i < 5; i++)
		ret.arr[i + 1] = rawbuf + BASE_LEN + (i * SUB_LEN);
	ret.length = 0;
	switch (baseId) {
		case 0:
			strcpy(ret.arr[0], GLOBAL1);
			break;
		case 1:
			strcpy(ret.arr[0], GLOBAL2);
			break;
		case 2:
			strcpy(ret.arr[0], LOCAL1);
			break;
		case 3:
			strcpy(ret.arr[0], LOCAL2);
			break;
	}
	for(i = 0; i < num_subs; i++){ //append the subscripts
		sprintf(ret.arr[i + 1], "sub%d", i);
	}
	ret.length=num_subs+1;
	return ret;
}

/* performs various SimpleThreadAPI functions based on a random number
 * on exit it spawns more threads until maxDepth is hit
 */
int runProc(testSettings* settings, int curDepth){
	int status, lockStatus;
	char errbuf[2048];
	int remainingOdds = 80 - (100 * settings->nestedTpRate);

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

	int action = rand() % 100;
	if (action < 20) { //ydb_set_s() case gets bias towards occurance
		logprint("set ", &t, "=\"MySecretValue\"");

		ydb_buffer_t value;
		YDB_LITERAL_TO_BUFFER("MySecretValue", &value);

		status = ydb_set_s(&basevar, t.length-1, subs, &value);
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_set_s()! %s\n", status, errbuf);
			}
		}

	} else if (action < 20 + remainingOdds * (2 / 15.0f)) { //ydb_get_s() case
		logprint("set x=$get(", &t, ")");
		ydb_buffer_t retvalue;
		YDB_MALLOC_BUFFER(&retvalue, 16);

		status = ydb_get_s(&basevar, t.length-1, subs, &retvalue);
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_get_s()! %s\n", status, errbuf);
			}
		}
		YDB_FREE_BUFFER(&retvalue);


	} else if (action < 20 + remainingOdds * (3 / 15.0f)) { //ydb_data_s() case
		logprint("set x=$data(", &t, ")");
		unsigned int retvalue;

		status = ydb_data_s(&basevar, t.length-1, subs, &retvalue);
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_data_s()! %s\n", status, errbuf);
			}
		} else {
			switch (retvalue) {
				case 0:
					status = YDB_OK;
					break;
				case 1:
					status = YDB_OK;
					break;
				case 10:
					status = YDB_OK;
					break;
				case 11:
					status = YDB_OK;
					break;
				default:
					printf("Unexpected data value issued!\n");
			}
		}

	} else if (action < 20 + remainingOdds * (4 / 15.0f)){ //ydb_node_next_s() and ydb_node_previous_s() case
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
		int startLen = t.length;
		int numsubs = t.length-1; //the starting length
		subsList = subs;      //the starting list
		while (status == YDB_OK){ //while not at the end, or received another error
			if (direction == 1){
				logprint("set x=$query(", &t, ",1)");
				status = ydb_node_next_s(&basevar, numsubs, subsList, &retnumsubs, retsubs);
			} else {
				logprint("set x=$query(", &t, ",-1)");
				status = ydb_node_previous_s(&basevar, numsubs, subsList, &retnumsubs, retsubs);
			}
			numsubs = retnumsubs;
			subsList = retsubs;//set the subsList to the new list
			if (status == YDB_OK){
				for(i=0; i < numsubs; i++){
					subsList[i].buf_addr[subsList[i].len_used] = '\0';
					strcpy(t.arr[i+1], subsList[i].buf_addr);
				}
				t.length = numsubs;
			}
			retnumsubs = 4; //reset the retsubs length
		}
		t.length = startLen;
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_node_*_s()! %s\n", status, errbuf);
			}
		}
		for(i = 0; i < retnumsubs; ++i)
		       YDB_FREE_BUFFER(&retsubs[i]);

	} else if (action < 20 + remainingOdds * (5 / 15.0f)){ //ydb_subscript_next_s() and ydb_subscript_previous_s() calls
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
				logprint("set x=$order(", &t, ",1)");
				status = ydb_subscript_next_s(&basevar, t.length-1, subs, &retvalue);
			} else {
				logprint("set x=$order(", &t, ",-1)");
				status = ydb_subscript_previous_s(&basevar, t.length-1, subs, &retvalue);
			}
			int done;
			if(t.length == 1){
				YDB_COPY_BUFFER_TO_BUFFER(&retvalue, &basevar, done); //if there are no subscripts replace the basevar
				basevar.buf_addr[basevar.len_used] = '\0';
				if (status == YDB_OK) strcpy(t.arr[0], basevar.buf_addr);
				YDB_ASSERT(done);
			} else {
				YDB_COPY_BUFFER_TO_BUFFER(&retvalue, &subs[t.length-2], done); //replace the last subscript with the next sibling
				subs[t.length-2].buf_addr[subs[t.length-2].len_used] = '\0';
				if (status == YDB_OK) strcpy(t.arr[t.length-1], subs[t.length-2].buf_addr);
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_subscript_*_s()! %s\n", status, errbuf);
			}
		}
		YDB_FREE_BUFFER(&retvalue);

	} else if (action < 20 + remainingOdds * (6 / 15.0f)){ //ydb_incr_s() case
		logprint("set x=$increment(", &t, ",$random(5))");
		int incr_amount = rand() / (RAND_MAX / 5); //rand int [0, 5]
		char incr_str[2];
		char printstr[16];
		ydb_buffer_t increment, retvalue;
		YDB_MALLOC_BUFFER(&retvalue, 16);
		YDB_MALLOC_BUFFER(&increment, 2);

		sprintf(incr_str, "%d", incr_amount);
		sprintf(printstr, "ydb_incr_s(%d)", incr_amount);
		YDB_COPY_STRING_TO_BUFFER(incr_str, &increment, status);

		status = ydb_incr_s(&basevar, t.length-1, subs, &increment, &retvalue);
		if (status != YDB_OK && status != YDB_TP_RESTART){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) issued from ydb_incr_s()! %s\n", status, errbuf);
		}
		YDB_FREE_BUFFER(&retvalue);
		YDB_FREE_BUFFER(&increment);

	} else if (action < 20 + remainingOdds * (7 / 15.0f)){ //ydb_lock*_s() case
		ydb_buffer_t lockVar;
		char lockBuf[13];	/* 10 bytes for max 4-byte pid + 2 bytes for "^a" + 1 byte for null terminator */
		lockVar.buf_addr = lockBuf;
		lockVar.len_alloc = sizeof(lockBuf);
		status = sprintf(lockVar.buf_addr, "^a%d", getpid());
		lockVar.len_used = status;
		unsigned long long lockTimeout = 0;

		logprint("lock ", &t, "");
		status = ydb_lock_s(lockTimeout, 1, &lockVar, 0, NULL);
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_lock_s() 1! %s\n", status, errbuf);
			}
		}

		logprint("lock +", &t, "");
		status = ydb_lock_incr_s(lockTimeout, &lockVar, 0, NULL);
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_lock_incr_s()! %s\n", status, errbuf);
			}
		}

		logprint("lock -", &t, "");
		status = ydb_lock_decr_s(&lockVar, 0, NULL);
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_lock_decr_s()! %s\n", status, errbuf);
			}
		}

		fprintf(logfile, " lock\n");
		status = ydb_lock_s(lockTimeout, 0);
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
				case YDB_TP_RESTART:
					break;
				default:
					ydb_zstatus(errbuf, sizeof(errbuf));
					printf("Unexpected return code (%d) issued from ydb_lock_s() 1! %s\n", status, errbuf);
			}
		}

	} else if (action < 20 + remainingOdds * (8 / 15.0f)){ //ydb_str2zwr case
		ydb_buffer_t strIn, strOut;
		char* compStr = "\"a\"_$C(10)_\"b\"_$C(9)_\"c\"";


		YDB_LITERAL_TO_BUFFER("a\nb\tc", &strIn);
		YDB_MALLOC_BUFFER(&strOut, 64);
		status = ydb_str2zwr_s(&strIn, &strOut);
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) issued from ydb_str2zwr_s()! %s\n", status, errbuf);
		}
		strOut.buf_addr[strOut.len_used] = '\0';
		if (0 != strcmp(compStr, strOut.buf_addr)){
			printf("ydb_str2zwr did not return the right value\n");
		}
		YDB_FREE_BUFFER(&strOut);

	} else if (action < 20 + remainingOdds * (9 / 15.0f)){ //ydb_zwr2str case
		ydb_buffer_t strIn, strOut;
		char* compStr = "a\nb\tc";


		YDB_LITERAL_TO_BUFFER("\"a\"_$C(10)_\"b\"_$C(9)_\"c\"", &strIn);
		YDB_MALLOC_BUFFER(&strOut, 64);
		status = ydb_zwr2str_s(&strIn, &strOut);
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) issued from ydb_zwr2str_s()! %s\n", status, errbuf);
		}
		strOut.buf_addr[strOut.len_used] = '\0';
		if (0 != strcmp(compStr, strOut.buf_addr)){
			printf("ydb_zwr2str did not return the right value\n");
		}
		YDB_FREE_BUFFER(&strOut);

	} else if (action < 20 + remainingOdds * (10 / 15.0f) && curDepth > 0){ //ydb_exit() case, don't call from main thread
		status = ydb_exit();
		if(status != -YDB_ERR_INVYDBEXIT){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) issued from ydb_exit()! %s\n", status, errbuf);
		}
		status = YDB_OK;

	} else if (action < 20 + remainingOdds * (11 / 15.0f)){ //ydb_init() case
		status = ydb_init();
		if(status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) issued from ydb_init()! %s\n", status, errbuf);
		}

	}else if (action < 20 + remainingOdds * (12 / 15.0f)){ //ydb_message() case
		ydb_buffer_t errOut;
		YDB_MALLOC_BUFFER(&errOut, 2048);

		status = ydb_message(-1, &errOut);
		if (status != YDB_OK){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) issued from ydb_message()! %s\n", status, errbuf);
		}
		if (errOut.len_used == 0){
			printf("ydb_message() did not correctly modify the buffer\n");
		}
		YDB_FREE_BUFFER(&errOut);

	} else if (action < 20 + remainingOdds * (13 / 15.0f)){ //ydb_zstatus() case
		ydb_zstatus(errbuf, sizeof(errbuf));//no check can be done here just ensuring no sig11
		status = YDB_OK;

	}else if (action < 20 + remainingOdds * (14 / 15.0f)){ //ydb_delete_s() case
		int type = rand();
		if (type < RAND_MAX/2){
			logprint("kill ", &t, "");
			status = ydb_delete_s(&basevar, t.length-1, subs, YDB_DEL_TREE);
		} else {
			logprint("zkill ", &t, "");
			status = ydb_delete_s(&basevar, t.length-1, subs, YDB_DEL_NODE);
		}
		if (status != YDB_OK && status != YDB_TP_RESTART){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) issued from ydb_delete_s()! %s\n", status, errbuf);
		}

	} else if (action < 20 + remainingOdds * (15 / 15.0f)){ //ydb_delete_excl_s() case
		if (t.arr[0][0] != '^'){ //if its a local
			int startLen = t.length;
			t.length = 1;
			logprint("kill (", &t, ")");
			t.length = startLen;
			status = ydb_delete_excl_s(1, &basevar);
		} else {
			status = YDB_OK;
		}
		if (status != YDB_OK && status != YDB_TP_RESTART){
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Unexpected return code (%d) issued from ydb_delete_excl_s()! %s\n", status, errbuf);
		}

	} else if (action <= 100){ //ydb_tp_s() case
		if (curDepth < settings->maxDepth){ //if max depth is reached, or the timeout is set, stop creating threads
			fprintf(logfile, " tstart ():(serial:transaction=\"BATCH\")\n");
			ydb_tpfnptr_t tpfn = &tpHelper;

			struct runProc_args args; //copy the test settings in to the struct
			args.settings = settings;
			args.curDepth = curDepth + 1;
			status = ydb_tp_s(tpfn, &args, "BATCH", 0 , NULL);
			fprintf(logfile, " tcommit\n");
		}
	} else {
		printf("Huh, random number out of range\n");
	}

	YDB_FREE_BUFFER(&basevar);
	for(i = 0; i < t.length-1; ++i)
		YDB_FREE_BUFFER(&subs[i]);
	free(t.arr[0]);//this is the raw buffer allocated at the top
	return status;
}

/* called by ydb_tp_s()
 * this will call runProc between [0, 19] times
 * with a 5% chance to do another ydb_tp_s()
 */
int tpHelper(void* tpfnparm){
	int status = YDB_OK;
	struct runProc_args* args = (struct runProc_args*) tpfnparm;
	int n = rand() % 20;
	int i;
	for(i = 0; i < n; ++i){
		args->settings->nestedTpRate = 0.05;
		status = runProc(args->settings, args->curDepth);
		if (YDB_OK != status) break;
	}
	return status;
}

void logprint(char *prefix, strArr *var, char* suffix){
	fprintf(logfile, " %s", prefix); // all lines must start with a space
	fprintf(logfile, var->length > 1 ? "%s(" : "%s", var->arr[0]); //if there are subscripts print a '('
	int i;
	for(i = 0; i < var->length - 2; i++) //print subscripts
		fprintf(logfile, "\"%s\",", var->arr[i+1]);
	if (var->length > 1)
		fprintf(logfile, "\"%s\")", var->arr[i+1]);//last subscript needs to be printed without a ','
	fprintf(logfile, "%s\n", suffix);
}

/* for ydb464 which needs the pid's of the forked processes
 * store them in a global ^pids(i) where i is the test iteration set by ydb464
 */
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
	status = ydb_subscript_previous_s(&pidGlobal, 1, pidSubs, &pidSubs[0]);
	YDB_ASSERT(status == YDB_OK);
	/* set the node to the pid of the process */
	pidSubs[1].buf_addr = pidStrB;
	pidSubs[1].len_alloc = 8;
	pidSubs[1].len_used = sprintf(pidSubs[1].buf_addr, "%d", getpid());
	status = ydb_set_s(&pidGlobal, 2, pidSubs, &pidSubs[1]);
	return status;
}
