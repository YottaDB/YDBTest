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
#include <unistd.h>
#include <math.h>
#include <time.h>
#include <sys/wait.h>
#include <errno.h>
#include "libyottadb.h"

#define RAND_INT(a, b) rand() % (b - a) + a

#define TRAN_AMT	1
#define START_CID	100001
#define	ACC_NEEDED	1000

#define ACC_GLOBAL	"^ZACN"
#define HIST_GLOBAL	"^ZHIST"
#define TRN_GLOBAL	"^ZTRNLOG"

/* thread globals */
#define NUM_THREADS	10
#define TEST_TIMEOUT 	120 // timeout in seconds to stop doing transactions
int idShift;
time_t startTime;


/* structs to pass arguments */
struct threadArgs{
	int guid;
	int user;
	int numRuns;
};

struct tpArgs{
	int ref;
	int from;
	int to;
	int amt;
	int user;
};

/* these structs emulate the functionality of classes
 * when combined with their respective functions
 * named Class_Func()
 */
typedef struct Account {
	int cid;
	int bal;
	int histSeq;
} Account;

typedef struct HistRecord {
	int cid;
	int histSeq;

	char comment[128];
	int amt;
	int endBal;
	int user;
} HistRecord;

typedef struct TrnLog {
	int guid;
	int tSeq;

	char comment[128];
	time_t tDateTime;
	int cid;
	int amt;
	int endBal;
	int user;
} TrnLog;

/* prototypes */
int childThread_driver(struct threadArgs* settings);
int childThread(struct threadArgs* args);
ydb_tpfnptr_t tpfn;
int postTransfer(void* tpfnparam);
int initData();

int Account_Load(ydb_buffer_t* basevarP, ydb_buffer_t* subP, int cid, Account* a);
int Account_Save(ydb_buffer_t* basevarP, ydb_buffer_t* subP, Account* a);
int Account_SetAccountKey(ydb_buffer_t* basevarP, ydb_buffer_t* subP, int cid);

int Hist_Save(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, HistRecord* h);
int Hist_SetHistKey(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, int cid, int histSeq);

int Trn_Save(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, TrnLog* t);
int Trn_SetTrnLogKey(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, int guid, int tseq);

/* creates 10 threads which each do TRAN_PER_THREAD transactions */
int main(){
	startTime = time(NULL);
	tpfn = &postTransfer;

	initData();

	int user = rand();
	struct threadArgs argsArr[NUM_THREADS];
	idShift = ceil(log10(NUM_THREADS));

	pid_t childProcess;

	int i;
	for(i = 0; i < NUM_THREADS; ++i){
		int guid = i;
		argsArr[i].guid = guid;
		argsArr[i].user = user;
		argsArr[i].numRuns = 0;

		childProcess = fork();
		if (childProcess == 0){
			return childThread_driver(&argsArr[i]);
		}
	}

	int status = 0;
	while(1){
		if ((i = wait(&status)) == -1){
			if (errno == EINTR) continue;
			break;
		}
	}

	return 0;
}

/* runs the test for TEST_TIMEOUT
 * runs most of the tests in batches of 100
 * to avoid (relatively) expensive time() calls
 */
int childThread_driver(struct threadArgs *settings){
	srand(getpid());
	/* estimation of test run time
	 * under-estimates in order to ensure TEST_TIMEOUT runtime
	 */
	int i;
	time_t estimate = 0;
	/* do operations in batches of 100
	 * checking time elapsed after each loop
	 */
	while (estimate < 110){
		for(i = 0; i < 100; i++){
			childThread(settings);
		}
		estimate = time(NULL) - startTime;
	}
	/* loop till TEST_TIMEOUT */
	while(time(NULL) - startTime < TEST_TIMEOUT){
		childThread(settings);
	}
	return 0;
}

/* Function that threads call
 * generates 2 account ID's
 * then uses ydb_tp_st() to call postTransfer
 */
int childThread(struct threadArgs *args){
	int status;
	struct tpArgs toPass;
	toPass.ref = args->guid + (args->numRuns * pow(10, idShift));
	toPass.from = 0;
	toPass.to = 0;
	toPass.amt = TRAN_AMT;
	toPass.from = START_CID + RAND_INT(0, ACC_NEEDED);
	toPass.to = START_CID + RAND_INT(0, ACC_NEEDED-1);
	if (toPass.from == toPass.to){
		toPass.to++;
	}
	status = ydb_tp_s(tpfn, &toPass, "BATCH", 0, NULL);
	YDB_ASSERT(status == YDB_OK);
	args->numRuns++;
}

/* driver function for the transaction
 * uses the simulated classes to modify the database
 */
int postTransfer(void* tpfnparam){
	struct tpArgs* args = (struct tpArgs*) tpfnparam;
	ydb_buffer_t keyAcctVar, keyAcctSubs[1];
	ydb_buffer_t keyHistVar, keyHistSubs[2];
	char keyAcctBuf[64], keyHistBuf1[128], keyHistBuf2[128];
	Account accountFrom, accountTo;
	HistRecord histFrom, histTo;
	TrnLog trnLogFrom, trnLogTo;
	int status;

	keyAcctSubs[0].buf_addr = keyAcctBuf;
	keyAcctSubs[0].len_used = 0;
	keyAcctSubs[0].len_alloc = sizeof(keyAcctBuf);

	keyHistSubs[0].buf_addr = keyHistBuf1;
	keyHistSubs[0].len_used = 0;
	keyHistSubs[0].len_alloc = sizeof(keyHistBuf1);

	keyHistSubs[1].buf_addr = keyHistBuf2;
	keyHistSubs[1].len_used = 0;
	keyHistSubs[1].len_alloc = sizeof(keyHistBuf2);

	/* Load the 2 account ID's modify their values and save them */
	status = Account_Load(&keyAcctVar, keyAcctSubs, args->from, &accountFrom);
	if (status == YDB_TP_RESTART) return status;
	status = Account_Load(&keyAcctVar, keyAcctSubs, args->to, &accountTo);
	if (status == YDB_TP_RESTART) return status;

	accountFrom.histSeq += 1;
	accountFrom.bal -= args->amt;
	accountTo.histSeq += 1;
	accountTo.bal += args->amt;

	status = Account_Save(&keyAcctVar, keyAcctSubs, &accountFrom);
	if (status == YDB_TP_RESTART) return status;
	status = Account_Save(&keyAcctVar, keyAcctSubs, &accountTo);
	if (status == YDB_TP_RESTART) return status;

	/* Load the 2 account histories add the new transaction to them */
	histFrom.cid = args->from;
	histFrom.histSeq = accountFrom.histSeq;
	status = sprintf(histFrom.comment, "Transfer to %d", args->to);
	YDB_ASSERT(status);
	histFrom.amt = -args->amt;
	histFrom.endBal = accountFrom.bal;
	histFrom.user = args->ref;
	status = Hist_Save(&keyHistVar, keyHistSubs, &histFrom);
	if (status == YDB_TP_RESTART) return status;

	histTo.cid = args->to;
	histTo.histSeq = accountTo.histSeq;
	status = sprintf(histTo.comment, "Transfer from %d", args->from);
	YDB_ASSERT(status);
	histTo.amt = args->amt;
	histTo.endBal = accountTo.bal;
	histTo.user = args->ref;
	status = Hist_Save(&keyHistVar, keyHistSubs, &histTo);
	if (status == YDB_TP_RESTART) return status;

	/* log the 2 transactions in the database */
	time_t dt = time(NULL);
	trnLogFrom.guid = args->ref;
	trnLogFrom.tSeq = 1;
	trnLogFrom.cid = args->from;
	status = sprintf(trnLogFrom.comment, "Transfer to %d", args->to);
	YDB_ASSERT(status);
	trnLogFrom.tDateTime = dt;
	trnLogFrom.amt = -args->amt;
	trnLogFrom.endBal = accountFrom.bal;
	trnLogFrom.user = args->user;
	status = Trn_Save(&keyHistVar, keyHistSubs, &trnLogFrom);
	if (status == YDB_TP_RESTART) return status;

	trnLogTo.guid = args->ref;
	trnLogTo.tSeq = 2;
	trnLogTo.cid = args->from;
	status = sprintf(trnLogTo.comment, "Transfer from %d", args->from);
	YDB_ASSERT(status);
	trnLogTo.tDateTime = dt;
	trnLogTo.amt = args->amt;
	trnLogTo.endBal = accountFrom.bal;
	trnLogTo.user = args->user;
	status = Trn_Save(&keyHistVar, keyHistSubs, &trnLogTo);
	if (status == YDB_TP_RESTART) return status;

	return 0;
}

/* fill the database with accounts */
int initData(){
	ydb_buffer_t basevar1, basevar2, subs[2], value1, value2;
	int status;

	int i;
	YDB_MALLOC_BUFFER(&subs[0], 64);

	YDB_LITERAL_TO_BUFFER(ACC_GLOBAL, &basevar1);
	YDB_LITERAL_TO_BUFFER(HIST_GLOBAL, &basevar2);
	YDB_LITERAL_TO_BUFFER("1|10000000", &value1);
	YDB_LITERAL_TO_BUFFER("Account Create||10000000", &value2);
	YDB_LITERAL_TO_BUFFER("1", &subs[1]);

	char buf[64];
	for(i = 0; i < ACC_NEEDED; ++i){
		status = sprintf(buf, "%d", START_CID + i);
		YDB_ASSERT(status);

		YDB_COPY_STRING_TO_BUFFER(buf, &subs[0], status);
		YDB_ASSERT(status);

		status = ydb_set_s(&basevar1, 1, &subs[0], &value1);
		YDB_ASSERT(status == YDB_OK);
		status = ydb_set_s(&basevar2, 2, subs, &value2);
		YDB_ASSERT(status == YDB_OK);
	}
	YDB_FREE_BUFFER(&subs[0]);
	return 0;
}


/* Account class functions */

/* Loads the account information in to the referenced pointers
 * Also initalizes the account structure
 */
int Account_Load (ydb_buffer_t* basevarP, ydb_buffer_t* subP, int cid, Account* a){
	ydb_buffer_t data;
	char dataBuf[64];
	int status;
	status = Account_SetAccountKey(basevarP, subP, cid);
	YDB_ASSERT(status == YDB_OK);

	data.buf_addr = dataBuf;
	data.len_used = 0;
	data.len_alloc = sizeof(dataBuf);
	status = ydb_get_s(basevarP, 1, subP, &data);
	if(status == YDB_TP_RESTART) return status;
	YDB_ASSERT(status == YDB_OK);

	data.buf_addr[data.len_used] = '\0';

	char buf[64];
	char* value;
	strcpy(buf, data.buf_addr);

	value = strtok(buf, "|");
	a->histSeq = atoi(value);

	value = strtok(NULL, "|");
	a->bal = atoi(value);

	a->cid = cid;

	return YDB_OK;
}

/* Saves the account information in to the database
 */
int Account_Save(ydb_buffer_t* basevarP, ydb_buffer_t* subP, Account* a){
	ydb_buffer_t data;
	int status;

	status = Account_SetAccountKey(basevarP, subP, a->cid);
	YDB_ASSERT(status == YDB_OK);

	char buf[64];
	status = sprintf(buf, "%d|%d", a->histSeq, a->bal);
	YDB_ASSERT(status);

	data.buf_addr = buf;
	data.len_used = status;
	data.len_alloc = sizeof(buf);
	YDB_ASSERT(status);

	status = ydb_set_s(basevarP, 1, subP, &data);
	if(status == YDB_TP_RESTART) return status;
	YDB_ASSERT(status == YDB_OK);

	return YDB_OK;
}

/* sets the account ydb_buffer_t varibles */
int Account_SetAccountKey(ydb_buffer_t* basevarP, ydb_buffer_t* subP, int cid){
	int status;
	YDB_LITERAL_TO_BUFFER(ACC_GLOBAL, basevarP);

	char buf[64];
	status = sprintf(buf, "%d", cid);
	YDB_ASSERT(status);

	YDB_COPY_STRING_TO_BUFFER(buf, subP, status);
	YDB_ASSERT(status);

	return YDB_OK;
}

/* History class functions */

int Hist_Save(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, HistRecord* h){
	ydb_buffer_t data;
	int status;

	status = Hist_SetHistKey(basevarP, subsP, h->cid, h->histSeq);
	YDB_ASSERT(status == YDB_OK);

	char buf[256];
	status = sprintf(buf, "%s|%d|%d|%d", h->comment, h->amt, h->endBal, h->user);
	YDB_ASSERT(status);
	data.buf_addr = buf;
	data.len_used = status;
	data.len_alloc = sizeof(buf);

	status = ydb_set_s(basevarP, 2, subsP, &data);
	if(status == YDB_TP_RESTART) return status;
	YDB_ASSERT(status == YDB_OK);

	return YDB_OK;
}

int Hist_SetHistKey(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, int cid, int histSeq){
	int status;

	YDB_LITERAL_TO_BUFFER(HIST_GLOBAL, basevarP);

	char buf[64];
	status = sprintf(buf, "%d", cid);
	YDB_ASSERT(status);
	YDB_COPY_STRING_TO_BUFFER(buf, &subsP[0], status);
	YDB_ASSERT(status);
	status = sprintf(buf, "%d", histSeq);
	YDB_ASSERT(status);
	YDB_COPY_STRING_TO_BUFFER(buf, &subsP[1], status);
	YDB_ASSERT(status);

	return YDB_OK;
}

/* TrnLog class functions */

int Trn_Save(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, TrnLog* t){
	ydb_buffer_t data;
	int status;

	status = Trn_SetTrnLogKey(basevarP, subsP, t->guid, t->tSeq);
	YDB_ASSERT(status == YDB_OK);

	char buf[128];
	status = sprintf(buf, "%d|%ld|%d|%d|%d|%d", t->guid, time(NULL), t->cid, t->amt, t->endBal, t->user);
	YDB_ASSERT(status);
	data.buf_addr = buf;
	data.len_used = status;
	data.len_alloc = sizeof(buf);


	status = ydb_set_s(basevarP, 2, subsP, &data);
	if(status == YDB_TP_RESTART) return status;
	YDB_ASSERT(status == YDB_OK);

	return YDB_OK;
}

int Trn_SetTrnLogKey(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, int guid, int tseq){
	int status;
	YDB_LITERAL_TO_BUFFER(TRN_GLOBAL, basevarP);


	char buf[64];
	status = sprintf(buf, "%d", guid);
	YDB_ASSERT(status);
	YDB_COPY_STRING_TO_BUFFER(buf, &subsP[0], status);
	YDB_ASSERT(status);

	status = sprintf(buf, "%d", tseq);
	YDB_ASSERT(status);
	YDB_COPY_STRING_TO_BUFFER(buf, &subsP[1], status);
	YDB_ASSERT(status);

	return YDB_OK;
}
