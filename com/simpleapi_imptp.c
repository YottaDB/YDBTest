/****************************************************************
 *								*
 * Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* This is a C program using simpleAPI to implement com/imptp.m */

#include "libyottadb.h"		/* for ydb_* macros/prototypes/typedefs */
#include "libydberrors.h"	/* for YDB_ERR_* macros */

#include <stdio.h>	/* for "printf" */
#include <unistd.h>	/* for "sysconf" and "usleep" */
#include <stdlib.h>	/* for "atoi" and "drand48" */
#include <string.h>	/* for "strtok" */
#include <time.h>	/* for "time" */
#include <sys/wait.h>	/* for "waitpid" prototype */
#include <errno.h>	/* for "errno" */

#include <sys/stat.h>	/* needed for "creat" */
#include <fcntl.h>	/* needed for "creat" */

#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" in assert */

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(getpid(), SIGILL)))

#define	YDB_COPY_BUFF_TO_BUFF(SRC, DST)				\
{								\
	int	copy_done;					\
								\
	YDB_COPY_BUFFER_TO_BUFFER(SRC, DST, copy_done);		\
	assert(copy_done);					\
}

#define	YDB_COPY_STRING_TO_BUFF(SRC, DST)			\
{								\
	int	copy_done;					\
								\
	YDB_COPY_STRING_TO_BUFFER(SRC, DST, copy_done);		\
	assert(copy_done);					\
}

#define	LOCK_TIMEOUT	(unsigned long long)900000000000	/* 900 * 10^9 nanoseconds == 900 seconds == 15 minutes */
#define	MAXCHILDREN	32
#define	MAXVALUELEN	256

pid_t		process_id;
char		valuebuff[MAXVALUELEN], pidvaluebuff[MAXVALUELEN], tmpvaluebuff[MAXVALUELEN], subscrbuff[YDB_MAX_SUBS + 1][MAXVALUELEN];
ydb_buffer_t	value, tmpvalue, pidvalue, subscr[YDB_MAX_SUBS + 1];
ydb_buffer_t	ylcl_jobcnt, ylcl_fillid, ylcl_istp, ylcl_jobid, ylcl_jobindex;
ydb_buffer_t	ygbl_pctimptp, ygbl_endloop, ygbl_cntloop, ygbl_cntseq, ygbl_pctsprgdeExcludeGbllist, ygbl_pctjobwait;
ydb_buffer_t	yisv_zroutines;
char		timeString[21];  /* space for "DD-MON-YEAR HH:MM:SS\0" */

int	impjob(int child);
char	*get_curtime(void);

/* Implements below M code in com/imptp.csh.
 *
 *	set jobcnt=$$^jobcnt
 *	w "do ^imptp(jobcnt)",!  do ^imptp(jobcnt)
 *
 */
int main(int argc, char *argv[])
{
	char		*ptr;
	int		i, jobcnt, fillid, istp, tpnoiso, dupset, crash, is_gtcm, repl_norepl, jobid, spannode;
	int		seed;
	int		status;
	int		child;
	unsigned int	data_value;
	pid_t		child_pid[MAXCHILDREN + 1];
	int		stat[MAXCHILDREN + 1], ret[MAXCHILDREN + 1];

	process_id = getpid();

	/* Initialize random number seed */
	seed = (time(NULL) * process_id);
	srand48(seed);

	/* Initialize all array variable names we are planning to later use */
	YDB_LITERAL_TO_BUFFER("jobcnt", &ylcl_jobcnt);
	YDB_LITERAL_TO_BUFFER("fillid", &ylcl_fillid);
	YDB_LITERAL_TO_BUFFER("istp", &ylcl_istp);
	YDB_LITERAL_TO_BUFFER("jobid", &ylcl_jobid);
	YDB_LITERAL_TO_BUFFER("jobindex", &ylcl_jobindex);
	YDB_LITERAL_TO_BUFFER("^%imptp", &ygbl_pctimptp);
	YDB_LITERAL_TO_BUFFER("^endloop", &ygbl_endloop);
	YDB_LITERAL_TO_BUFFER("^cntloop", &ygbl_cntloop);
	YDB_LITERAL_TO_BUFFER("^cntseq", &ygbl_cntseq);
	YDB_LITERAL_TO_BUFFER("^%sprgdeExcludeGbllist", &ygbl_pctsprgdeExcludeGbllist);
	YDB_LITERAL_TO_BUFFER("^%jobwait", &ygbl_pctjobwait);
	YDB_LITERAL_TO_BUFFER("$zroutines", &yisv_zroutines);

	value.buf_addr = valuebuff;
	value.len_alloc = sizeof(valuebuff);
	pidvalue.buf_addr = pidvaluebuff;
	pidvalue.len_alloc = sizeof(pidvaluebuff);
	tmpvalue.buf_addr = tmpvaluebuff;
	tmpvalue.len_alloc = sizeof(tmpvaluebuff);
	for (i = 0; i < YDB_MAX_SUBS + 1; i++)
	{
		subscr[i].buf_addr = subscrbuff[i];
		subscr[i].len_alloc = sizeof(subscrbuff[i]);
	}

	/* Implement M code : set jobcnt=$$^jobcnt */
	ptr = getenv("gtm_test_jobcnt");
	jobcnt = (NULL != ptr) ? atoi(ptr) : 0;
	if (0 == jobcnt)
		jobcnt = 5;
	printf("jobcnt = %d\n", jobcnt);
	value.len_used = sprintf(value.buf_addr, "%d", jobcnt);
	status = ydb_set_s(&ylcl_jobcnt, 0, NULL, &value);
	assert(YDB_OK == status);

	/* Implement M entryref : imptp^imptp.
	 * Infinite multiprocess TP or non-TP database fill program.
	 */
	/* w "Start Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),! */
	value.len_used = sprintf(value.buf_addr, "Start Time of parent:%s", get_curtime());
	assert(value.len_used < value.len_alloc);
	printf("%s\n", value.buf_addr);
	/* w "$zro=",$zro,! */
	status = ydb_get_s(&yisv_zroutines, 0, NULL, &value);
	assert(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	printf("$zro=%s\n", value.buf_addr);
	/* w "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),! */
	printf("PID: %d\nIn hex: 0x%x\n", process_id, process_id);

	/* ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	 * ; Start processing test system paramters
	 * ;
	 * ; istp = 0 non-tp
	 * ; istp = 1 TP
	 * ; istp = 2 ZTP
	 */

	/* set fillid=+$ztrnlnm("gtm_test_dbfillid") */
	ptr = getenv("gtm_test_dbfillid");
	fillid = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", fillid);
	status = ydb_set_s(&ylcl_fillid, 0, NULL, &value);
	assert(YDB_OK == status);

	/* if $ztrnlnm("gtm_test_tp")="NON_TP"  do
	 * .  set istp=0
	 * .  write "It is Non-TP",!
	 * else  do
	 * .  if $ztrnlnm("gtm_test_dbfill")="IMPZTP" set istp=2  write "It is ZTP",!
	 * .  else  set istp=1  write "It is TP",!
	 * set ^%imptp(fillid,"istp")=istp
	 */
	ptr = getenv("gtm_test_tp");
	if ((NULL != ptr) && !strcmp(ptr, "NON_TP"))
	{
		istp = 0;
		printf("It is Non-TP\n");
	} else
	{
		ptr = getenv("gtm_test_dbfill");
		if ((NULL != ptr) && !strcmp(ptr, "IMPZTP"))
		{
			istp = 2;
			printf("It is ZTP\n");
			assert(0);	/* We cannot simulate ZTP usage in simpleAPI but don't expect test system is using this */
		} else
		{
			istp = 1;
			printf("It is TP\n");
		}
	}
	YDB_COPY_BUFF_TO_BUFF(&value, &subscr[0]);
	YDB_COPY_STRING_TO_BUFF("istp", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", istp);
	status = ydb_set_s(&ylcl_istp, 0, NULL, &value);
	assert(YDB_OK == status);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/*
	 * if $ztrnlnm("gtm_test_tptype")="ONLINE" set ^%imptp(fillid,"tptype")="ONLINE"
	 * else  set ^%imptp(fillid,"tptype")="BATCH"
	 * ;
	 */
	ptr = getenv("gtm_test_tptype");
	YDB_COPY_STRING_TO_BUFF("tptype", &subscr[1]);
	if ((NULL != ptr) && !strcmp(ptr, "ONLINE"))
	{
		YDB_COPY_STRING_TO_BUFF("ONLINE", &value);
	} else
	{
		YDB_COPY_STRING_TO_BUFF("BATCH", &value);
	}
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/*
	 * ; Randomly 50% time use noisolation for TP if gtm_test_noisolation not defined, and only if not already set.
	 * if '$data(^%imptp(fillid,"tpnoiso")) do
	 * .  if (istp=1)&(($ztrnlnm("gtm_test_noisolation")="TPNOISO")!($random(2)=1)) set ^%imptp(fillid,"tpnoiso")=1
	 * .  else  set ^%imptp(fillid,"tpnoiso")=0
	 */
	YDB_COPY_STRING_TO_BUFF("tpnoiso", &subscr[1]);
	status = ydb_data_s(&ygbl_pctimptp, 2, subscr, &data_value);
	assert(YDB_OK == status);
	if (!data_value)
	{
		tpnoiso = 0;
		if (1 == istp)
		{
			ptr = getenv("gtm_test_noisolation");
			if (((NULL != ptr) && !strcmp(ptr, "TPNOISO")) || (int)(2 * drand48()))
				tpnoiso = 1;
		}
		value.len_used = sprintf(value.buf_addr, "%d", tpnoiso);
		status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
		assert(YDB_OK == status);
	}

	/* ;
	 * ; Randomly 50% time use optimization for redundant sets, only if not already set.
	 * if '$data(^%imptp(fillid,"dupset")) do
	 * .  if ($random(2)=1) set ^%imptp(fillid,"dupset")=1
	 * .  else  set ^%imptp(fillid,"dupset")=0
	 */
	YDB_COPY_STRING_TO_BUFF("dupset", &subscr[1]);
	status = ydb_data_s(&ygbl_pctimptp, 2, subscr, &data_value);
	assert(YDB_OK == status);
	if (!data_value)
	{
		dupset = (int)(2 * drand48());
		value.len_used = sprintf(value.buf_addr, "%d", dupset);
		status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
		assert(YDB_OK == status);
	}

	/* ;
	 * set ^%imptp(fillid,"crash")=+$ztrnlnm("gtm_test_crash")
	 */
	YDB_COPY_STRING_TO_BUFF("crash", &subscr[1]);
	ptr = getenv("gtm_test_crash");
	crash = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", crash);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/* ;
	 * set ^%imptp(fillid,"gtcm")=+$ztrnlnm("gtm_test_is_gtcm")
	 */
	YDB_COPY_STRING_TO_BUFF("gtcm", &subscr[1]);
	ptr = getenv("gtm_test_is_gtcm");
	is_gtcm = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", is_gtcm);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/* ;
	 * set ^%imptp(fillid,"skipreg")=+$ztrnlnm("gtm_test_repl_norepl")	; How many regions to skip dbfill
	 */
	YDB_COPY_STRING_TO_BUFF("skipreg", &subscr[1]);
	ptr = getenv("gtm_test_repl_norepl");
	repl_norepl = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", repl_norepl);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/* ;
	 * set jobid=+$ztrnlnm("gtm_test_jobid")
	 */
	ptr = getenv("gtm_test_jobid");
	jobid = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", jobid);
	status = ydb_set_s(&ylcl_jobid, 0, NULL, &value);
	assert(YDB_OK == status);

	/* set ^%imptp("fillid",jobid)=fillid */
	YDB_COPY_BUFF_TO_BUFF(&subscr[0], &tmpvalue);	/* save "fillid" subscript for later restore */
	YDB_COPY_STRING_TO_BUFF("fillid", &subscr[0]);
	YDB_COPY_BUFF_TO_BUFF(&value, &subscr[1]);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &tmpvalue);
	assert(YDB_OK == status);

	/* ; Grab the key and record size from DSE
	 * do get^datinfo("^%imptp("_fillid_")")
	 */
	status = ydb_ci("getdatinfo");	/* Use call-in for this as it is a long M routine and not worth migrating to simpleAPI */
	assert(YDB_OK == status);

	/* set ^%imptp(fillid,"gtm_test_spannode")=+$ztrnlnm("gtm_test_spannode") */
	YDB_COPY_BUFF_TO_BUFF(&tmpvalue, &subscr[0]);	/* restore saved "fillid" subscript back into subscr[0] */
	YDB_COPY_STRING_TO_BUFF("gtm_test_spannode", &subscr[1]);
	ptr = getenv("gtm_test_spannode");
	spannode = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", spannode);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/* ;
	 * ; if triggers are installed, the following will invoke the trigger
	 * ; for ^%imptp(fillid,"trigger") defined in test/com_u/imptp.trg and set
	 * ; ^%imptp(fillid,"trigger") to 1
	 * set ^%imptp(fillid,"trigger")=0
	 */
	YDB_COPY_STRING_TO_BUFF("trigger", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/* ;
	 * if $DATA(^%imptp(fillid,"totaljob"))=0 set ^%imptp(fillid,"totaljob")=jobcnt
	 * else  if ^%imptp(fillid,"totaljob")'=jobcnt  w "IMPTP-E-MISMATCH: Job number mismatch",!  zwr ^%imptp  h
	 */
	YDB_COPY_STRING_TO_BUFF("totaljob", &subscr[1]);
	status = ydb_data_s(&ygbl_pctimptp, 2, subscr, &data_value);
	assert(YDB_OK == status);
	if (!data_value)
	{
		value.len_used = sprintf(value.buf_addr, "%d", jobcnt);
		status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
		assert(YDB_OK == status);
	} else
	{
		status = ydb_get_s(&ygbl_pctimptp, 2, subscr, &value);
		assert(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		if (atoi(value.buf_addr) != jobcnt)
		{
			printf("IMPTP-E-MISMATCH: Job number mismatch : ^%%imptp(fillid,totaljob) = %d : jobcnt = %d\n",
				atoi(value.buf_addr), jobcnt);
			return -1;
		}
	}

	/* ;
	 * ; End of processing test system paramters
	 * ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	 * ;
	 * ;   This program fills database randomly using primitive root of a field.
	 * ;   Say, w is the primitive root and we have 5 jobs
	 * ;   Job 1 : Sets index w^0, w^5, w^10 etc.
	 * ;   Job 2 : Sets index w^1, w^6, w^11 etc.
	 * ;   Job 3 : Sets index w^2, w^7, w^12 etc.
	 * ;   Job 4 : Sets index w^3, w^8, w^13 etc.
	 * ;   Job 5 : Sets index w^4, w^9, w^14 etc.
	 * ;   In above example nroot = w^5
	 * ;   In above example root =  w
	 * ;   Precalculate primitive root for a prime and set them here
	 */
	/* set ^%imptp(fillid,"prime")=50000017	;Precalculated */
	YDB_COPY_STRING_TO_BUFF("prime", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 50000017);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/* set ^%imptp(fillid,"root")=5		;Precalculated */
	YDB_COPY_STRING_TO_BUFF("root", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 5);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/* set ^endloop(fillid)=0	;To stop infinite loop */
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_endloop, 1, subscr, &value);
	assert(YDB_OK == status);

	/* if $data(^cntloop(fillid))=0 set ^cntloop(fillid)=0	; Initialize before attempting $incr in child */
	status = ydb_data_s(&ygbl_cntloop, 1, subscr, &data_value);
	assert(YDB_OK == status);
	if (!data_value)
	{
		value.len_used = sprintf(value.buf_addr, "%d", 0);
		status = ydb_set_s(&ygbl_cntloop, 1, subscr, &value);
		assert(YDB_OK == status);
	}

	/* if $data(^cntseq(fillid))=0 set ^cntseq(fillid)=0	; Initialize before attempting $incr in child */
	status = ydb_data_s(&ygbl_cntseq, 1, subscr, &data_value);
	assert(YDB_OK == status);
	if (!data_value)
	{
		value.len_used = sprintf(value.buf_addr, "%d", 0);
		status = ydb_set_s(&ygbl_cntseq, 1, subscr, &value);
		assert(YDB_OK == status);
	}

	/* ;
	 * set ^%imptp(fillid,"jsyncnt")=0	; To count number of processes that are ready to be killed by crash scripts
	 */
	YDB_COPY_STRING_TO_BUFF("jsyncnt", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	assert(YDB_OK == status);

	/* ; If test is running with gtm_test_spanreg'=0, we want to make sure the *xarr global variables continue to
	 * ; cover ALL regions involved in the updates as this is relied upon in Stage 11 of imptp updates.
	 * ; See <GTM_2168_imptp_dbcheck_verification_fail> for details. An easy way to achieve this is by
	 * ; unconditionally (gtm_test_spanreg is 0 or not) excluding all these globals from random mapping to multiple regions.
	 *
	 * set gblprefix="abcdefgh"
	 * for i=1:1:$length(gblprefix) set ^%sprgdeExcludeGbllist($extract(gblprefix,i)_"ndxarr")=""
	 */
	YDB_COPY_BUFF_TO_BUFF(&subscr[0], &tmpvalue);	/* save "fillid" subscript for later restore */
	YDB_COPY_STRING_TO_BUFF("andxarr", &subscr[0]);
	YDB_COPY_STRING_TO_BUFF("", &value);
	for (i = 0; i < 8; i++)
	{
		subscr[0].buf_addr[0] = 'a' + i;	/* Get 'a', 'b', 'c', ... 'h' in every iteration of loop */
		status = ydb_set_s(&ygbl_pctsprgdeExcludeGbllist, 1, subscr, &value);
		assert(YDB_OK == status);
	}
	/* Before forking off children, make sure all buffered IO is flushed out (or else the children would inherit
	 * the unflushed buffers and will show up duplicated in the children's stdout/stderr.
	 */
	fflush(NULL);

	/* Since "jmaxwait" local variable (in com/imptp.m) is undefined at this point, the caller
	 * will invoke "endtp.csh" later to wait for the children to die. Therefore set ^%jobwait global
	 * to point to those pids.
	 */
	/* set ^%jobwait(jobid,"njobs")=njobs (com/job.m) */
	subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", jobid);
	YDB_COPY_STRING_TO_BUFF("njobs", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", jobcnt);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	assert(YDB_OK == status);
	/* set ^("jmaxwait")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jmaxwait", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 7200);	/* 7200 value copied from "set jdefwait=7200" in com/job.m */
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	assert(YDB_OK == status);
	/* set ^("jdefwait")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jdefwait", &subscr[1]);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	assert(YDB_OK == status);
	/* set ^("jprint")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jprint", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	assert(YDB_OK == status);
	/* set ^("jroutine")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jroutine", &subscr[1]);
	YDB_COPY_STRING_TO_BUFF("impjob_imptp", &value);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	assert(YDB_OK == status);
	/* set ^("jmjoname")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jmjoname", &subscr[1]);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	assert(YDB_OK == status);
	/* set ^("jnoerrchk")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jnoerrchk", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	assert(YDB_OK == status);
	/* Call "ydb_child_init" in parent BEFORE fork to ensure it is a no-op */
	status = ydb_child_init(NULL);
	assert(YDB_OK == status);
	/* do ^job("impjob^imptp",jobcnt,"""""")	: com/imptp.m */
	for (child = 1; child <= jobcnt; child++)
	{
		child_pid[child] = fork();
		assert(0 <= child_pid[child]);
		if (0 == child_pid[child])
		{
			status = ydb_child_init(NULL);	/* needed in child pid right after a fork() */
			assert(YDB_OK == status);
			status = ydb_child_init(NULL);	/* do it again to ensure it is a no-op the second time */
			assert(YDB_OK == status);
			impjob(child);	/* this is the child */
			return YDB_OK;
		}
		/* for i=1:1:njobs  set ^(i)=jobindex(i)	: com/job.m */
		subscr[1].len_used = sprintf(subscr[1].buf_addr, "%d", child);
		value.len_used = sprintf(value.buf_addr, "%d", child_pid[child]);
		status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
		assert(YDB_OK == status);
		/* set jobindex(index)=$zjob			: com/job.m */
		status = ydb_set_s(&ylcl_jobindex, 1, &subscr[1], &value);
		assert(YDB_OK == status);
	}
	/* Call "ydb_child_init" in parent AFTER fork to ensure it is a no-op */
	status = ydb_child_init(NULL);
	assert(YDB_OK == status);
	/* do writecrashfileifneeded			: com/job.m */
	status = ydb_ci("writecrashfileifneeded");	/* Use call-in for this as it not worth migrating to simpleAPI */
	assert(YDB_OK == status);
	/* do writejobinfofileifneeded			: com/job.m */
	status = ydb_ci("writejobinfofileifneeded");	/* Use call-in for this as it not worth migrating to simpleAPI */
	assert(YDB_OK == status);
	/* ; Wait until the first update on all regions happen
	 * set start=$horolog
	 * for  set stop=$horolog quit:^cntloop(fillid)  quit:($$^difftime(stop,start)>300)  hang 1
	 * write:$$^difftime(stop,start)>300 "TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!",!
	 */
	YDB_COPY_BUFF_TO_BUFF(&tmpvalue, &subscr[0]);	/* restore saved "fillid" subscript back into subscr[0] */
	for ( ; ; )
	{
		status = ydb_get_s(&ygbl_cntloop, 1, subscr, &value);
		assert(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		if (0 != atoi(value.buf_addr))
			break;
		sleep(1);
	}
	/* ;
	 * ; Wait for all M child processes to start and reach a point when it is safe to simulate crash
	 * set timeout=600	; 10 minutes to start and reach the sync point for kill
	 * for i=1:1:600 hang 1 quit:^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"totaljob")
	 * if ^%imptp(fillid,"jsyncnt")<^%imptp(fillid,"totaljob") do
	 * . write "TEST-E-imptp.m time out for jobs to start and synch after ",timeout," seconds",!
	 * . zwrite ^%imptp
	 */
	YDB_COPY_STRING_TO_BUFF("jsyncnt", &subscr[1]);
	YDB_COPY_BUFF_TO_BUFF(&subscr[0], &subscr[2]);
	YDB_COPY_STRING_TO_BUFF("totaljob", &subscr[3]);
	for ( ; ; )
	{
		status = ydb_get_s(&ygbl_pctimptp, 2, subscr, &value);	/* Get ^%imptp(fillid,"jsyncnt") */
		assert(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		status = ydb_get_s(&ygbl_pctimptp, 2, &subscr[2], &tmpvalue);	/* Get ^%imptp(fillid,"totaljob") */
		assert(YDB_OK == status);
		tmpvalue.buf_addr[tmpvalue.len_used] = '\0';
		if (atoi(value.buf_addr) == atoi(tmpvalue.buf_addr))
			break;
		sleep(1);
	}
	/* ;
	 * do writeinfofileifneeded
	 */
	ptr = getenv("gtm_test_onlinerollback");
	if ((NULL != ptr) && !strcmp(ptr, "TRUE"))
		assert(FALSE);	/* online rollback & simpleAPI cannot be supported for now (see comment in imptp.csh) */

	/* write "End   Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),! */
	value.len_used = sprintf(value.buf_addr, "End   Time of parent:%s", get_curtime());
	assert(value.len_used < value.len_alloc);
	printf("%s\n", value.buf_addr);

	/* quit */
	return YDB_OK;
}

/* Implements M entryref impjob^imptp */
int	impjob(int childnum)
{
	int	outfd, errfd, newfd;
	char	outfile[64], errfile[64];
	int	status;
	int	jobid;
	char	*ptr;

	process_id = getpid();
	pidvalue.len_used = sprintf(pidvalue.buf_addr, "%d", (int)process_id);

	ptr = getenv("gtm_test_jobid");
	jobid = (NULL != ptr) ? atoi(ptr) : 0;

	/* Set stdout & stderr to child specific files */
	if (0 != jobid)
		sprintf(outfile, "impjob_imptp%d.mjo%d", jobid, childnum);
	else
		sprintf(outfile, "impjob_imptp.mjo%d", childnum);
	outfd = creat(outfile, 0666);
	assert(-1 != outfd);
	newfd = dup2(outfd, 1);
	assert(1 == newfd);
	if (0 != jobid)
		sprintf(errfile, "impjob_imptp%d.mje%d", jobid, childnum);
	else
		sprintf(errfile, "impjob_imptp.mje%d", childnum);
	errfd = creat(errfile, 0666);
	assert(-1 != errfd);
	newfd = dup2(errfd, 2);
	assert(2 == newfd);

	/* Since we reset 1 & 2 file descriptors, need to invoke the below function.
	 * Or else we would end up with error messages in *.mjo (instead of *.mje).
	 */
	status = ydb_stdout_stderr_adjust();
	assert(YDB_OK == status);

	/* set jobindex=index */
	value.len_used = sprintf(value.buf_addr, "%d", childnum);
	status = ydb_set_s(&ylcl_jobindex, 0, NULL, &value);
	assert(YDB_OK == status);

	/* NARSTODO : Temporarily use call-in until full simpleAPI migration is done */
	/* NARSTODO : Randomize ydb_ci vs simpleAPI in the child */
	/* do impjob^imptp */
	status = ydb_ci("impjob");
	/* If the caller is the "gtm8086" subtest, it creates a situation where JNLEXTEND or JNLSWITCHFAIL
	 * errors can happen in the imptp child process and that is expected. Account for that in the below assert.
	 */
	assert((YDB_OK == status)
		|| (!memcmp(getenv("test_subtest_name"), "gtm8086", sizeof("gtm8086"))
			&& (-YDB_ERR_JNLEXTEND == status) || (-YDB_ERR_JNLSWITCHFAIL == status)));
	return YDB_OK;
}

/* Returns current time in global variable "timeString" */
char *get_curtime()
{
	time_t current_time;
	struct tm * time_info;

	time(&current_time);
	time_info = localtime(&current_time);

	strftime(timeString, sizeof(timeString), "%d-%b-%Y %H:%M:%S", time_info);
	return timeString;
}
