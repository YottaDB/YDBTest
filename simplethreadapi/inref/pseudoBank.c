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
#include <pthread.h>
#include <math.h>
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
#define TIMEOUT_LEN	120
pthread_t tids[NUM_THREADS];
pthread_t timeout;
int isTimeout;
int idShift;

/* structs to pass arguments */
struct threadArgs{
	int guid;
	int user;
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
void* toggleTimeout();
void* childThread(void* args);
ydb_tp2fnptr_t tpfn;
int postTransfer(uint64_t tptoken, ydb_buffer_t* errstrP, void* tpfnparam);
int initData();

int Account_Load(uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subP, int cid, Account* a);
int Account_Save(uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subP, Account* a);
int Account_SetAccountKey(ydb_buffer_t* basevarP, ydb_buffer_t* subP, int cid);

int Hist_Save(uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subsP, HistRecord* h);
int Hist_SetHistKey(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, int cid, int histSeq);

int Trn_Load(uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subsP, int guid, int tseq, TrnLog* t);
int Trn_Save(uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subsP, TrnLog* t);
int Trn_SetTrnLogKey(ydb_buffer_t* basevarP, ydb_buffer_t* subsP, int guid, int tseq);


/* creates 10 threads which each do TRAN_PER_THREAD transactions */
int main(){
	tpfn = &postTransfer;

	initData();

	int user = rand();
	struct threadArgs argsArr[NUM_THREADS];
	idShift = ceil(log10(NUM_THREADS));

	isTimeout = 0;
	pthread_create(&timeout, NULL, &toggleTimeout, NULL);

	int i;
	for(i = 0; i < NUM_THREADS; ++i){
		int guid = i;
		argsArr[i].guid = guid;
		argsArr[i].user = user;

		pthread_create(&tids[i], NULL, &childThread, &argsArr[i]);
	}

	for(i = 0; i < NUM_THREADS; ++i){
		pthread_join(tids[i], NULL);
	}
	return 0;
}

void* toggleTimeout(){
	sleep(TIMEOUT_LEN);
	isTimeout = 1;
	return 0;
}

/* Function that threads call
 * generates 2 account ID's
 * then uses ydb_tp_st() to call postTransfer
 */
void* childThread(void* args){
	struct threadArgs* info = (struct threadArgs*) args;
	int status;
	struct tpArgs toPass;
	int i = 0;
	while(!isTimeout){
		toPass.ref = info->guid + (i * pow(10, idShift));
		toPass.from = 0;
		toPass.to = 0;
		toPass.amt = TRAN_AMT;
		toPass.user = info->user;
		while (toPass.from == toPass.to){
			toPass.from = START_CID + RAND_INT(0, ACC_NEEDED);
			toPass.to = START_CID + RAND_INT(0, ACC_NEEDED);
		}
		status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, &toPass, "BATCH", 0, NULL);
		YDB_ASSERT(status == YDB_OK);
		++i;
	}
}

/* driver function for the transaction
 * uses the simulated classes to modify the database
 */
int postTransfer(uint64_t tptoken, ydb_buffer_t* errstrP, void* tpfnparam){
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
	status = Account_Load(tptoken, errstrP, &keyAcctVar, keyAcctSubs, args->from, &accountFrom);
	status = Account_Load(tptoken, errstrP, &keyAcctVar, keyAcctSubs, args->to, &accountTo);

	accountFrom.histSeq += 1;
	accountFrom.bal -= args->amt;
	accountTo.histSeq += 1;
	accountTo.bal += args->amt;

	status = Account_Save(tptoken, errstrP, &keyAcctVar, keyAcctSubs, &accountFrom);
	status = Account_Save(tptoken, errstrP, &keyAcctVar, keyAcctSubs, &accountTo);

	/* Load the 2 account histories add the new transaction to them */
	histFrom.cid = args->from;
	histFrom.histSeq = accountFrom.histSeq;
	status = sprintf(histFrom.comment, "Transfer to %d", args->to);
	YDB_ASSERT(status);
	histFrom.amt = -args->amt;
	histFrom.endBal = accountFrom.bal;
	histFrom.user = args->ref;
	status = Hist_Save(tptoken, errstrP, &keyHistVar, keyHistSubs, &histFrom);
	if (status == YDB_TP_RESTART) return status;

	histTo.cid = args->to;
	histTo.histSeq = accountTo.histSeq;
	status = sprintf(histTo.comment, "Transfer from %d", args->from);
	YDB_ASSERT(status);
	histTo.amt = args->amt;
	histTo.endBal = accountTo.bal;
	histTo.user = args->ref;
	status = Hist_Save(tptoken, errstrP, &keyHistVar, keyHistSubs, &histTo);
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
	status = Trn_Save(tptoken, errstrP, &keyHistVar, keyHistSubs, &trnLogFrom);
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
	status = Trn_Save(tptoken, errstrP, &keyHistVar, keyHistSubs, &trnLogTo);
	if (status == YDB_TP_RESTART) return status;

	return 0;
}

/* fill the database with accounts */
int initData(){
	ydb_buffer_t basevar1, basevar2, subs[2], value1, value2;
	ydb_buffer_t errstr;
	int status;

	int i;
	YDB_MALLOC_BUFFER(&subs[0], 64);
	YDB_MALLOC_BUFFER(&errstr, 128);

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

		status = ydb_set_st(YDB_NOTTP, &errstr, &basevar1, 1, &subs[0], &value1);
		YDB_ASSERT(status == YDB_OK);
		status = ydb_set_st(YDB_NOTTP, &errstr, &basevar2, 2, subs, &value2);
		YDB_ASSERT(status == YDB_OK);
	}
	YDB_FREE_BUFFER(&subs[0]);
	YDB_FREE_BUFFER(&errstr);
	return 0;
}


/* Account class functions */

/* Loads the account information in to the referenced pointers
 * Also initializes the account structure
 */
int Account_Load (uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subP, int cid, Account* a){
	ydb_buffer_t data;
	char dataBuf[64];
	int status;
	status = Account_SetAccountKey(basevarP, subP, cid);
	YDB_ASSERT(status == YDB_OK);

	data.buf_addr = dataBuf;
	data.len_used = 0;
	data.len_alloc = sizeof(dataBuf);
	status = ydb_get_st(tptoken, errstrP, basevarP, 1, subP, &data);
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
int Account_Save(uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subP, Account* a){
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

	status = ydb_set_st(tptoken, errstrP, basevarP, 1, subP, &data);
	if(status == YDB_TP_RESTART) return status;
	YDB_ASSERT(status == YDB_OK);

	return YDB_OK;
}

/* sets the account ydb_buffer_t variables */
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

int Hist_Save(uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subsP, HistRecord* h){
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

	status = ydb_set_st(tptoken, errstrP, basevarP, 2, subsP, &data);
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

int Trn_Save(uint64_t tptoken, ydb_buffer_t* errstrP, ydb_buffer_t* basevarP, ydb_buffer_t* subsP, TrnLog* t){
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


	status = ydb_set_st(tptoken, errstrP, basevarP, 2, subsP, &data);
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
