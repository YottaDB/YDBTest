/****************************************************************
 *								*
 * Copyright (c) 2018-2019 YottaDB LLC. and/or its subsidiaries.*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* This is a C program using SimpleThreadAPI to implement com/imptp.m.
 * This is a copy of com/simpleapi_imptp.c with the following changes.
 *	1) ydb_*_s() calls (SimpleAPI) replaced by ydb_*_st() calls (SimpleThreadAPI) for the most part.
 *	2) SimpleAPI is still used in the parent process (as SimpleThreadAPI cannot be used before a "fork")
 */

#include "libyottadb.h"		/* for ydb_* macros/prototypes/typedefs and YDB_ERR_* macros */

#include <stdio.h>	/* for "printf" */
#include <unistd.h>	/* for "sysconf" and "usleep" */
#include <stdlib.h>	/* for "atoi" and "drand48" */
#include <string.h>	/* for "strtok" */
#include <time.h>	/* for "time" */
#include <sys/wait.h>	/* for "waitpid" prototype */
#include <errno.h>	/* for "errno" */

#include <sys/stat.h>	/* needed for "creat" */
#include <fcntl.h>	/* needed for "creat" */

#define	YDB_COPY_BUFF_TO_BUFF(SRC, DST)				\
{								\
	int	copy_done;					\
								\
	YDB_COPY_BUFFER_TO_BUFFER(SRC, DST, copy_done);		\
	YDB_ASSERT(copy_done);					\
}

#define	YDB_COPY_STRING_TO_BUFF(SRC, DST)			\
{								\
	int	copy_done;					\
								\
	YDB_COPY_STRING_TO_BUFFER(SRC, DST, copy_done);		\
	YDB_ASSERT(copy_done);					\
}

#define	LOCK_TIMEOUT	(unsigned long long)900000000000	/* 900 * 10^9 nanoseconds == 900 seconds == 15 minutes */
#define	MAXCHILDREN	32
#define	MAXVALUELEN	256		/* this is maximum length of value returned for most nodes (keeps buffers small) */
#define	BIGMAXVALUELEN	(MAXVALUELEN*6)	/* certain values can go more than MAXVALUELEN so we need this in that case */
#define	NUMSUBS		8		/* maximum number of subscripts needed */

/* valMAXbuff and valuebuff are defined as buffers of size BIGMAXVALUELEN (1K)
 * as valMAX variable in imptp.m can go to lengths of 871 etc.
 */
pid_t		process_id;
char		valuebuff[BIGMAXVALUELEN], pidvaluebuff[MAXVALUELEN], tmpvaluebuff[MAXVALUELEN];
char		subscrbuff[NUMSUBS][BIGMAXVALUELEN];
ydb_buffer_t	value, tmpvalue, pidvalue, subscr[NUMSUBS];
ydb_buffer_t	ylcl_jobcnt, ylcl_fillid, ylcl_istp, ylcl_jobid, ylcl_jobindex;
ydb_buffer_t	ylcl_jobno, ylcl_tptype, ylcl_ztrcmd, ylcl_trigname, ylcl_fulltrig, ylcl_dztrig, ylcl_I, ylcl_loop;
ydb_buffer_t	ylcl_keysize, ylcl_recsize, ylcl_span;
ydb_buffer_t	ylcl_subsMAX, ylcl_val, ylcl_valALT, ylcl_valMAX, ylcl_subs;
ydb_buffer_t	ylcl_lfence, ylcl_trigger, ylcl_crash, ylcl_orlbkintp;
ydb_buffer_t	ygbl_pctimptp, ygbl_endloop, ygbl_cntloop, ygbl_cntseq, ygbl_pctsprgdeExcludeGbllist, ygbl_pctjobwait, ygbl_lasti;
ydb_buffer_t	ygbl_arandom, ygbl_brandomv, ygbl_zdummy, ygbl_crandomva, ygbl_drandomvariable, ygbl_erandomvariableimptp;
ydb_buffer_t	ygbl_frandomvariableinimptp, ygbl_grandomvariableinimptpfill, ygbl_hrandomvariableinimptpfilling;
ydb_buffer_t	ygbl_irandomvariableinimptpfillprgrm, ygbl_jrandomvariableinimptpfillprogram;
ydb_buffer_t	ygbl_antp, ygbl_bntp, ygbl_cntp, ygbl_dntp, ygbl_entp, ygbl_fntp, ygbl_gntp, ygbl_hntp, ygbl_intp;
ydb_buffer_t	yisv_zroutines, yisv_trestart;
char		timeString[21];  /* space for "DD-MON-YEAR HH:MM:SS\0" */
char		tptypebuff[MAXVALUELEN];
char		subsMAXbuff[BIGMAXVALUELEN], valbuff[MAXVALUELEN], valALTbuff[MAXVALUELEN], valMAXbuff[BIGMAXVALUELEN];
char		subsbuff[MAXVALUELEN], Ibuff[MAXVALUELEN];
ydb_buffer_t	ybuff_tptype, ybuff_subsMAX, ybuff_val, ybuff_valALT, ybuff_valMAX, ybuff_subs, ybuff_I;
int		crash, trigger;

ci_name_descriptor	getdatinfo_cid, writecrashfileifneeded_cid, writejobinfofileifneeded_cid, tpnoiso_cid;
ci_name_descriptor	dupsetnoop_cid, helper1_cid, helper2_cid, helper3_cid, noop_cid, ztwormstr_cid, ztrcmd_cid;
ci_name_descriptor	imptpdztrig_cid;

int	impjob(int child);
char	*get_curtime(void);
int	tpfn_stage1();
int	tpfn_stage3();

/* Initialize a "ci_name_descriptor" structure for later use by "ydb_cip" or "ydb_cip_t" */
#define	YDB_CIP_DESC_INIT(CID, RTNNAME)				\
{								\
	CID.rtn_name.address = (RTNNAME);			\
	CID.rtn_name.length = strlen(CID.rtn_name.address);	\
	CID.handle = NULL;					\
}

/* Implements below M code in com/imptp.csh.
 *
 *	set jobcnt=$$^jobcnt
 *	w "do ^imptp(jobcnt)",!  do ^imptp(jobcnt)
 *
 */
int main(int argc, char *argv[])
{
	char		*ptr;
	int		i, jobcnt, fillid, istp, tpnoiso, dupset, is_gtcm, repl_norepl, jobid, spannode;
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
	YDB_LITERAL_TO_BUFFER("jobno", &ylcl_jobno);
	YDB_LITERAL_TO_BUFFER("tptype", &ylcl_tptype);
	YDB_LITERAL_TO_BUFFER("ztrcmd", &ylcl_ztrcmd);
	YDB_LITERAL_TO_BUFFER("trigname", &ylcl_trigname);
	YDB_LITERAL_TO_BUFFER("fulltrig", &ylcl_fulltrig);
	YDB_LITERAL_TO_BUFFER("dztrig", &ylcl_dztrig);
	YDB_LITERAL_TO_BUFFER("I", &ylcl_I);
	YDB_LITERAL_TO_BUFFER("loop", &ylcl_loop);
	YDB_LITERAL_TO_BUFFER("keysize", &ylcl_keysize);
	YDB_LITERAL_TO_BUFFER("recsize", &ylcl_recsize);
	YDB_LITERAL_TO_BUFFER("span", &ylcl_span);
	YDB_LITERAL_TO_BUFFER("subsMAX", &ylcl_subsMAX);
	YDB_LITERAL_TO_BUFFER("val", &ylcl_val);
	YDB_LITERAL_TO_BUFFER("valALT", &ylcl_valALT);
	YDB_LITERAL_TO_BUFFER("valMAX", &ylcl_valMAX);
	YDB_LITERAL_TO_BUFFER("subs", &ylcl_subs);
	YDB_LITERAL_TO_BUFFER("lfence", &ylcl_lfence);
	YDB_LITERAL_TO_BUFFER("trigger", &ylcl_trigger);
	YDB_LITERAL_TO_BUFFER("crash", &ylcl_crash);
	YDB_LITERAL_TO_BUFFER("orlbkintp", &ylcl_orlbkintp);
	YDB_LITERAL_TO_BUFFER("^%imptp", &ygbl_pctimptp);
	YDB_LITERAL_TO_BUFFER("^endloop", &ygbl_endloop);
	YDB_LITERAL_TO_BUFFER("^cntloop", &ygbl_cntloop);
	YDB_LITERAL_TO_BUFFER("^cntseq", &ygbl_cntseq);
	YDB_LITERAL_TO_BUFFER("^%sprgdeExcludeGbllist", &ygbl_pctsprgdeExcludeGbllist);
	YDB_LITERAL_TO_BUFFER("^%jobwait", &ygbl_pctjobwait);
	YDB_LITERAL_TO_BUFFER("^lasti", &ygbl_lasti);
	YDB_LITERAL_TO_BUFFER("^arandom", &ygbl_arandom);
	YDB_LITERAL_TO_BUFFER("^brandomv", &ygbl_brandomv);
	YDB_LITERAL_TO_BUFFER("^zdummy", &ygbl_zdummy);
	YDB_LITERAL_TO_BUFFER("^crandomva", &ygbl_crandomva);
	YDB_LITERAL_TO_BUFFER("^drandomvariable", &ygbl_drandomvariable);
	YDB_LITERAL_TO_BUFFER("^erandomvariableimptp", &ygbl_erandomvariableimptp);
	YDB_LITERAL_TO_BUFFER("^frandomvariableinimptp", &ygbl_frandomvariableinimptp);
	YDB_LITERAL_TO_BUFFER("^grandomvariableinimptpfill", &ygbl_grandomvariableinimptpfill);
	YDB_LITERAL_TO_BUFFER("^hrandomvariableinimptpfilling", &ygbl_hrandomvariableinimptpfilling);
	YDB_LITERAL_TO_BUFFER("^irandomvariableinimptpfillprgrm", &ygbl_irandomvariableinimptpfillprgrm);
	/* Note that SimpleAPI/SimpleThreadAPI issues an error if length is > 32 (unlike YottaDB M environment where the name is
	 * silently truncated) so truncate the name as much as needed to keep it valid.
	 */
	YDB_LITERAL_TO_BUFFER("^jrandomvariableinimptpfillprogr", &ygbl_jrandomvariableinimptpfillprogram);
	YDB_LITERAL_TO_BUFFER("^antp", &ygbl_antp);
	YDB_LITERAL_TO_BUFFER("^bntp", &ygbl_bntp);
	YDB_LITERAL_TO_BUFFER("^cntp", &ygbl_cntp);
	YDB_LITERAL_TO_BUFFER("^dntp", &ygbl_dntp);
	YDB_LITERAL_TO_BUFFER("^entp", &ygbl_entp);
	YDB_LITERAL_TO_BUFFER("^fntp", &ygbl_fntp);
	YDB_LITERAL_TO_BUFFER("^gntp", &ygbl_gntp);
	YDB_LITERAL_TO_BUFFER("^hntp", &ygbl_hntp);
	YDB_LITERAL_TO_BUFFER("^intp", &ygbl_intp);
	YDB_LITERAL_TO_BUFFER("$zroutines", &yisv_zroutines);
	YDB_LITERAL_TO_BUFFER("$trestart", &yisv_trestart);

	/* Initialize ydb_cip descriptors */
	YDB_CIP_DESC_INIT(getdatinfo_cid, "getdatinfo");
	YDB_CIP_DESC_INIT(writecrashfileifneeded_cid,   "writecrashfileifneeded");
	YDB_CIP_DESC_INIT(writejobinfofileifneeded_cid, "writejobinfofileifneeded");
	YDB_CIP_DESC_INIT(tpnoiso_cid, "tpnoiso");
	YDB_CIP_DESC_INIT(dupsetnoop_cid, "dupsetnoop");
	YDB_CIP_DESC_INIT(helper1_cid, "helper1");
	YDB_CIP_DESC_INIT(helper2_cid, "helper2");
	YDB_CIP_DESC_INIT(helper3_cid, "helper3");
	YDB_CIP_DESC_INIT(noop_cid, "noop");
	YDB_CIP_DESC_INIT(ztwormstr_cid, "ztwormstr");
	YDB_CIP_DESC_INIT(ztrcmd_cid, "ztrcmd");
	YDB_CIP_DESC_INIT(imptpdztrig_cid, "imptpdztrig");

	/* Initialize ydb_buffer_t structures */
	value.buf_addr = valuebuff;
	value.len_alloc = sizeof(valuebuff);
	pidvalue.buf_addr = pidvaluebuff;
	pidvalue.len_alloc = sizeof(pidvaluebuff);
	tmpvalue.buf_addr = tmpvaluebuff;
	tmpvalue.len_alloc = sizeof(tmpvaluebuff);
	for (i = 0; i < NUMSUBS; i++)
	{
		subscr[i].buf_addr = subscrbuff[i];
		subscr[i].len_alloc = sizeof(subscrbuff[i]);
	}
	ybuff_tptype.buf_addr = tptypebuff;
	ybuff_tptype.len_alloc = sizeof(tptypebuff);
	ybuff_subsMAX.buf_addr = subsMAXbuff;
	ybuff_subsMAX.len_alloc = sizeof(subsMAXbuff);
	ybuff_val.buf_addr = valbuff;
	ybuff_val.len_alloc = sizeof(valbuff);
	ybuff_valALT.buf_addr = valALTbuff;
	ybuff_valALT.len_alloc = sizeof(valALTbuff);
	ybuff_valMAX.buf_addr = valMAXbuff;
	ybuff_valMAX.len_alloc = sizeof(valMAXbuff);
	ybuff_subs.buf_addr = subsbuff;
	ybuff_subs.len_alloc = sizeof(subsbuff);
	ybuff_I.buf_addr = Ibuff;
	ybuff_I.len_alloc = sizeof(Ibuff);

	/* Implement M code : set jobcnt=$$^jobcnt */
	ptr = getenv("gtm_test_jobcnt");
	jobcnt = (NULL != ptr) ? atoi(ptr) : 0;
	if (0 == jobcnt)
		jobcnt = 5;
	printf("jobcnt = %d\n", jobcnt);
	value.len_used = sprintf(value.buf_addr, "%d", jobcnt);
	/* Use SimpleAPI calls in the parent before the fork. This is because if we use SimpleThreadAPI we will
	 * have to do an exec() after the fork() (or else a STAPIFORKEXEC error is issued). Once we fork off, we
	 * can start using SimpleThreadAPI in the child (which is the bulk of the test).
	 */
	status = ydb_set_s(&ylcl_jobcnt, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* Implement M entryref : imptp^imptp.
	 * Infinite multiprocess TP or non-TP database fill program.
	 */
	/* w "Start Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),! */
	value.len_used = sprintf(value.buf_addr, "Start Time of parent:%s", get_curtime());
	YDB_ASSERT(value.len_used < value.len_alloc);
	printf("%s\n", value.buf_addr);
	/* w "$zro=",$zro,! */
	status = ydb_get_s(&yisv_zroutines, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
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
	YDB_ASSERT(YDB_OK == status);

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
			YDB_ASSERT(0);	/* We cannot simulate ZTP usage in SimpleAPI/SimpleThreadAPI but don't expect test system is using this */
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
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

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
	YDB_ASSERT(YDB_OK == status);

	/*
	 * ; Randomly 50% time use noisolation for TP if gtm_test_noisolation not defined, and only if not already set.
	 * if '$data(^%imptp(fillid,"tpnoiso")) do
	 * .  if (istp=1)&(($ztrnlnm("gtm_test_noisolation")="TPNOISO")!($random(2)=1)) set ^%imptp(fillid,"tpnoiso")=1
	 * .  else  set ^%imptp(fillid,"tpnoiso")=0
	 */
	YDB_COPY_STRING_TO_BUFF("tpnoiso", &subscr[1]);
	status = ydb_data_s(&ygbl_pctimptp, 2, subscr, &data_value);
	YDB_ASSERT(YDB_OK == status);
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
		YDB_ASSERT(YDB_OK == status);
	}

	/* ;
	 * ; Randomly 50% time use optimization for redundant sets, only if not already set.
	 * if '$data(^%imptp(fillid,"dupset")) do
	 * .  if ($random(2)=1) set ^%imptp(fillid,"dupset")=1
	 * .  else  set ^%imptp(fillid,"dupset")=0
	 */
	YDB_COPY_STRING_TO_BUFF("dupset", &subscr[1]);
	status = ydb_data_s(&ygbl_pctimptp, 2, subscr, &data_value);
	YDB_ASSERT(YDB_OK == status);
	if (!data_value)
	{
		dupset = (int)(2 * drand48());
		value.len_used = sprintf(value.buf_addr, "%d", dupset);
		status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
	}

	/* ;
	 * set ^%imptp(fillid,"crash")=+$ztrnlnm("gtm_test_crash")
	 */
	YDB_COPY_STRING_TO_BUFF("crash", &subscr[1]);
	ptr = getenv("gtm_test_crash");
	crash = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", crash);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

	/* ;
	 * set ^%imptp(fillid,"gtcm")=+$ztrnlnm("gtm_test_is_gtcm")
	 */
	YDB_COPY_STRING_TO_BUFF("gtcm", &subscr[1]);
	ptr = getenv("gtm_test_is_gtcm");
	is_gtcm = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", is_gtcm);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

	/* ;
	 * set ^%imptp(fillid,"skipreg")=+$ztrnlnm("gtm_test_repl_norepl")	; How many regions to skip dbfill
	 */
	YDB_COPY_STRING_TO_BUFF("skipreg", &subscr[1]);
	ptr = getenv("gtm_test_repl_norepl");
	repl_norepl = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", repl_norepl);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

	/* ;
	 * set jobid=+$ztrnlnm("gtm_test_jobid")
	 */
	ptr = getenv("gtm_test_jobid");
	jobid = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", jobid);
	status = ydb_set_s(&ylcl_jobid, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* set ^%imptp("fillid",jobid)=fillid */
	YDB_COPY_BUFF_TO_BUFF(&subscr[0], &tmpvalue);	/* save "fillid" subscript for later restore */
	YDB_COPY_STRING_TO_BUFF("fillid", &subscr[0]);
	YDB_COPY_BUFF_TO_BUFF(&value, &subscr[1]);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &tmpvalue);
	YDB_ASSERT(YDB_OK == status);

	/* Throughout this C program small portions of code are implemented using call-ins (instead of SimpleAPI/SimpleThreadAPI)
	 * because either it is not possible to migrate or because it is easier to keep it as is (no benefit of extra
	 * test coverage for SimpleAPI/SimpleThreadAPI).
	 */
	/* ; Grab the key and record size from DSE
	 * do get^datinfo("^%imptp("_fillid_")")
	 */
	status = ydb_cip(&getdatinfo_cid);
	YDB_ASSERT(YDB_OK == status);

	/* set ^%imptp(fillid,"gtm_test_spannode")=+$ztrnlnm("gtm_test_spannode") */
	YDB_COPY_BUFF_TO_BUFF(&tmpvalue, &subscr[0]);	/* restore saved "fillid" subscript back into subscr[0] */
	YDB_COPY_STRING_TO_BUFF("gtm_test_spannode", &subscr[1]);
	ptr = getenv("gtm_test_spannode");
	spannode = (NULL != ptr) ? atoi(ptr) : 0;
	value.len_used = sprintf(value.buf_addr, "%d", spannode);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

	/* ;
	 * ; if triggers are installed, the following will invoke the trigger
	 * ; for ^%imptp(fillid,"trigger") defined in test/com_u/imptp.trg and set
	 * ; ^%imptp(fillid,"trigger") to 1
	 * set ^%imptp(fillid,"trigger")=0
	 */
	YDB_COPY_STRING_TO_BUFF("trigger", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

	/* ;
	 * if $DATA(^%imptp(fillid,"totaljob"))=0 set ^%imptp(fillid,"totaljob")=jobcnt
	 * else  if ^%imptp(fillid,"totaljob")'=jobcnt  w "IMPTP-E-MISMATCH: Job number mismatch",!  zwr ^%imptp  h
	 */
	YDB_COPY_STRING_TO_BUFF("totaljob", &subscr[1]);
	status = ydb_data_s(&ygbl_pctimptp, 2, subscr, &data_value);
	YDB_ASSERT(YDB_OK == status);
	if (!data_value)
	{
		value.len_used = sprintf(value.buf_addr, "%d", jobcnt);
		status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
	} else
	{
		status = ydb_get_s(&ygbl_pctimptp, 2, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
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
	YDB_ASSERT(YDB_OK == status);

	/* set ^%imptp(fillid,"root")=5		;Precalculated */
	YDB_COPY_STRING_TO_BUFF("root", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 5);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

	/* set ^endloop(fillid)=0	;To stop infinite loop */
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_endloop, 1, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

	/* if $data(^cntloop(fillid))=0 set ^cntloop(fillid)=0	; Initialize before attempting $incr in child */
	status = ydb_data_s(&ygbl_cntloop, 1, subscr, &data_value);
	YDB_ASSERT(YDB_OK == status);
	if (!data_value)
	{
		value.len_used = sprintf(value.buf_addr, "%d", 0);
		status = ydb_set_s(&ygbl_cntloop, 1, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
	}

	/* if $data(^cntseq(fillid))=0 set ^cntseq(fillid)=0	; Initialize before attempting $incr in child */
	status = ydb_data_s(&ygbl_cntseq, 1, subscr, &data_value);
	YDB_ASSERT(YDB_OK == status);
	if (!data_value)
	{
		value.len_used = sprintf(value.buf_addr, "%d", 0);
		status = ydb_set_s(&ygbl_cntseq, 1, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
	}

	/* ;
	 * set ^%imptp(fillid,"jsyncnt")=0	; To count number of processes that are ready to be killed by crash scripts
	 */
	YDB_COPY_STRING_TO_BUFF("jsyncnt", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);

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
		YDB_ASSERT(YDB_OK == status);
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
	YDB_ASSERT(YDB_OK == status);
	/* set ^("jmaxwait")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jmaxwait", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 7200);	/* 7200 value copied from "set jdefwait=7200" in com/job.m */
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	/* set ^("jdefwait")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jdefwait", &subscr[1]);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	/* set ^("jprint")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jprint", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	/* set ^("jroutine")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jroutine", &subscr[1]);
	YDB_COPY_STRING_TO_BUFF("impjob_imptp", &value);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	/* set ^("jmjoname")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jmjoname", &subscr[1]);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	/* set ^("jnoerrchk")				: com/job.m */
	YDB_COPY_STRING_TO_BUFF("jnoerrchk", &subscr[1]);
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	/* Wherever "ydb_child_init" is called below, randomly choose not to call it.
	 * It should not be required at all since it is now automatically invoked after a "fork" by YottaDB.
	 */
	/* Call "ydb_child_init" in parent BEFORE fork to ensure it is a no-op */
	if ((int)(2 * drand48()))
	{
		status = ydb_child_init(NULL);
		YDB_ASSERT(YDB_OK == status);
	}
	/* do ^job("impjob^imptp",jobcnt,"""""")	: com/imptp.m */
	for (child = 1; child <= jobcnt; child++)
	{
		child_pid[child] = fork();
		YDB_ASSERT(0 <= child_pid[child]);
		if (0 == child_pid[child])
		{
			if ((int)(2 * drand48()))
			{
				status = ydb_child_init(NULL);	/* needed in child pid right after a fork() */
				YDB_ASSERT(YDB_OK == status);
			}
			if ((int)(2 * drand48()))
			{
				status = ydb_child_init(NULL);	/* do it again to ensure it is a no-op the second time */
				YDB_ASSERT(YDB_OK == status);
			}
			impjob(child);	/* this is the child */
			return YDB_OK;
		}
		/* for i=1:1:njobs  set ^(i)=jobindex(i)	: com/job.m */
		subscr[1].len_used = sprintf(subscr[1].buf_addr, "%d", child);
		value.len_used = sprintf(value.buf_addr, "%d", child_pid[child]);
		status = ydb_set_s(&ygbl_pctjobwait, 2, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
		/* set jobindex(index)=$zjob			: com/job.m */
		status = ydb_set_s(&ylcl_jobindex, 1, &subscr[1], &value);
		YDB_ASSERT(YDB_OK == status);
	}
	if ((int)(2 * drand48()))
	{	/* Call "ydb_child_init" in parent AFTER fork to ensure it is a no-op */
		status = ydb_child_init(NULL);
		YDB_ASSERT(YDB_OK == status);
	}
	/* do writecrashfileifneeded			: com/job.m */
	status = ydb_cip(&writecrashfileifneeded_cid);
	YDB_ASSERT(YDB_OK == status);
	/* do writejobinfofileifneeded			: com/job.m */
	status = ydb_cip(&writejobinfofileifneeded_cid);
	YDB_ASSERT(YDB_OK == status);
	/* ; Wait until the first update on all regions happen
	 * set start=$horolog
	 * for  set stop=$horolog quit:^cntloop(fillid)  quit:($$^difftime(stop,start)>300)  hang 1
	 * write:$$^difftime(stop,start)>300 "TEST-W-FIRSTUPD None of the jobs completed its first update across all the regions after 5 minutes!",!
	 */
	YDB_COPY_BUFF_TO_BUFF(&tmpvalue, &subscr[0]);	/* restore saved "fillid" subscript back into subscr[0] */
	for ( ; ; )
	{
		status = ydb_get_s(&ygbl_cntloop, 1, subscr, &value);
		YDB_ASSERT(YDB_OK == status);
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
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		status = ydb_get_s(&ygbl_pctimptp, 2, &subscr[2], &tmpvalue);	/* Get ^%imptp(fillid,"totaljob") */
		YDB_ASSERT(YDB_OK == status);
		tmpvalue.buf_addr[tmpvalue.len_used] = '\0';
		if (atoi(value.buf_addr) == atoi(tmpvalue.buf_addr))
			break;
		sleep(1);
	}
	/* do writeinfofileifneeded */
	ptr = getenv("gtm_test_onlinerollback");
	if ((NULL != ptr) && !strcmp(ptr, "TRUE"))
		YDB_ASSERT(FALSE);	/* online rollback & SimpleAPI/SimpleThreadAPI cannot be supported for now (see comment in imptp.csh) */

	/* write "End   Time of parent:",$ZD($H,"DD-MON-YEAR 24:60:SS"),! */
	value.len_used = sprintf(value.buf_addr, "End   Time of parent:%s", get_curtime());
	YDB_ASSERT(value.len_used < value.len_alloc);
	printf("%s\n", value.buf_addr);

	/* quit */
	return YDB_OK;
}

/* Implements M entryref impjob^imptp */
int	impjob(int childnum)
{
	int		outfd, errfd, newfd;
	char		outfile[64], errfile[64];
	int		status;
	int		jobid;
	int		rand;
	char		*ptr;
	int		prime, root;
	int		jobno, jobcnt, fillid, istp, tpnoiso, dupset, skipreg, gtcm;
	int		keysize, recsize, span;
	int		ztr, dztrig;
	int		lfence, nroot, i, lasti, top;
	int		I, J, loop;
	int		parm_array[16];
	int		is_gtm8086_subtest;
	ydb_buffer_t	starvar, *valueptr;

	process_id = getpid();
	pidvalue.len_used = sprintf(pidvalue.buf_addr, "%d", (int)process_id);

	ptr = getenv("gtm_test_jobid");
	jobid = (NULL != ptr) ? atoi(ptr) : 0;

	/* Set stdout & stderr to child specific files */
	sprintf(outfile, "impjob_imptp%d.mjo%d", jobid, childnum);
	outfd = creat(outfile, 0666);
	YDB_ASSERT(-1 != outfd);
	newfd = dup2(outfd, 1);
	YDB_ASSERT(1 == newfd);
	sprintf(errfile, "impjob_imptp%d.mje%d", jobid, childnum);
	errfd = creat(errfile, 0666);
	YDB_ASSERT(-1 != errfd);
	newfd = dup2(errfd, 2);
	YDB_ASSERT(2 == newfd);

	/* Initialize all array variable names we are planning to later use. Some have already been initialized for us in parent. */

	/* Since we reset 1 & 2 file descriptors, need to invoke the below function.
	 * Or else we would end up with error messages in *.mjo (instead of *.mje).
	 */
	status = ydb_stdout_stderr_adjust_t(YDB_NOTTP, NULL);
	YDB_ASSERT(YDB_OK == status);

	/* set jobindex=index */
	value.len_used = sprintf(value.buf_addr, "%d", childnum);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_jobindex, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	rand = (int)(2 * drand48());
	is_gtm8086_subtest = (!memcmp(getenv("test_subtest_name"), "gtm8086", sizeof("gtm8086")));
	/* If the caller is the "gtm8086" subtest, it creates a situation where JNLEXTEND or JNLSWITCHFAIL
	 * errors can happen in the imptp child process and that is expected. This is easily handled if we
	 * invoke the entire child process using impjob^imptp. If we use SimpleAPI/SimpleThreadAPI for this, all the ydb_*_st()
	 * calls need to be checked for return status to allow for JNLEXTEND/JNLSWITCHFAIL and it gets clumsy.
	 * Since SimpleAPI/SimpleThreadAPI gets good test coverage through imptp in many dozen tests, we choose to use call-ins
	 * only for this specific test.
	 */
	if (is_gtm8086_subtest)
		rand = 1;
	if (rand)
	{	/* Randomly chose ydb_ci method to run child (impjob^imptp) */
		/* do impjob^imptp */
		status = ydb_ci_t(YDB_NOTTP, NULL, "impjob"); /* Use "ydb_ci_t" (not ydb_cip_t) intentionally to test "ydb_ci_t" */
		/* If the caller is the "gtm8086" subtest, it creates a situation where JNLEXTEND or JNLSWITCHFAIL
		 * errors can happen in the imptp child process and that is expected. Account for that in the below YDB_ASSERT.
		 */
		YDB_ASSERT((YDB_OK == status)
			|| (is_gtm8086_subtest && (-YDB_ERR_JNLEXTEND == status) || (-YDB_ERR_JNLSWITCHFAIL == status)));
		return YDB_OK;
	}
	/* Randomly chose SimpleAPI/SimpleThreadAPI method to run child (impjob^imptp) */
	/* write "Start Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),!	*/
	value.len_used = sprintf(value.buf_addr, "Start Time : %s", get_curtime());
	YDB_ASSERT(value.len_used < value.len_alloc);
	printf("%s\n", value.buf_addr);
	/* write "$zro=",$zro,!	*/
	status = ydb_get_st(YDB_NOTTP, NULL, &yisv_zroutines, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	printf("$zro=%s\n", value.buf_addr);

	/* if $ztrnlnm("gtm_test_onlinerollback")="TRUE" merge %imptp=^%imptp */
	/* No need to translate the above M line as parent would have YDB_ASSERT failed in that case. */

	/* set jobno=jobindex	; Set by job.m ; not using $job makes imptp resumable after a crash! */
	jobno = childnum;
	value.len_used = sprintf(value.buf_addr, "%d", jobno);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_jobno, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* set jobid=+$ztrnlnm("gtm_test_jobid") */
	/* Already done earlier in this function */

	/* set fillid=^%imptp("fillid",jobid) */
	YDB_COPY_STRING_TO_BUFF("fillid", &subscr[0]);
	subscr[1].len_used = sprintf(subscr[1].buf_addr, "%d", jobid);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	fillid = atoi(value.buf_addr);

	/* set jobcnt=^%imptp(fillid,"totaljob") */
	subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", fillid);
	YDB_COPY_STRING_TO_BUFF("totaljob", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	jobcnt = atoi(value.buf_addr);

	/* set prime=^%imptp(fillid,"prime") */
	YDB_COPY_STRING_TO_BUFF("prime", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	prime = atoi(value.buf_addr);

	/* set root=^%imptp(fillid,"root") */
	YDB_COPY_STRING_TO_BUFF("root", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	root = atoi(value.buf_addr);

	/* set top=+$GET(^%imptp(fillid,"top")) */
	YDB_COPY_STRING_TO_BUFF("top", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	if (YDB_ERR_GVUNDEF == status)
		top = 0;
	else
	{
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		top = atoi(value.buf_addr);
	}

	/* if top=0 set top=prime\jobcnt */
	if (0 == top)
		top = prime / jobcnt;

	/* set istp=^%imptp(fillid,"istp") */
	YDB_COPY_STRING_TO_BUFF("istp", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	istp = atoi(value.buf_addr);

	/* set tptype=^%imptp(fillid,"tptype") */
	YDB_COPY_STRING_TO_BUFF("tptype", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_tptype, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	/* Initialize "tptype" global string for later use by various functions */
	YDB_COPY_BUFF_TO_BUFF(&value, &ybuff_tptype);
	ybuff_tptype.buf_addr[ybuff_tptype.len_used] = '\0';

	/* set tpnoiso=^%imptp(fillid,"tpnoiso") */
	YDB_COPY_STRING_TO_BUFF("tpnoiso", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	tpnoiso = atoi(value.buf_addr);

	/* set dupset=^%imptp(fillid,"dupset") */
	YDB_COPY_STRING_TO_BUFF("dupset", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	dupset = atoi(value.buf_addr);

	/* set skipreg=^%imptp(fillid,"skipreg") */
	YDB_COPY_STRING_TO_BUFF("skipreg", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	skipreg = atoi(value.buf_addr);

	/* set crash=^%imptp(fillid,"crash") */
	YDB_COPY_STRING_TO_BUFF("crash", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	crash = atoi(value.buf_addr);
	/* Set "crash" M variable */
	value.len_used = sprintf(value.buf_addr, "%d", crash);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_crash, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* set gtcm=^%imptp(fillid,"gtcm") */
	YDB_COPY_STRING_TO_BUFF("gtcm", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	gtcm = atoi(value.buf_addr);

	/* ; ONLINE ROLLBACK - BEGIN
	 * ; Randomly 50% when in TP, switch the online rollback TP mechanism to restart outside of TP
	 * ;	orlbkintp = 0 disable online rollback support - this is the default
	 * ;	orlbkintp = 1 use the TP rollback mechanism outside of TP, should be true for only TP
	 * ;	orlbkintp = 2 use the TP rollback mechanism inside of TP, should be true for only TP
	 * set orlbkintp=0
	 * new ORLBKRESUME
	 * if $ztrnlnm("gtm_test_onlinerollback")="TRUE" do init^orlbkresume("imptp",$zlevel,"ERROR^imptp") if istp=1 set orlbkintp=($random(2)+1)
	 * ; ONLINE ROLLBACK -  END
	 */
	/* The above online rollback section does not need to be migrated since we never run SimpleAPI/SimpleThreadAPI against online rollback */
	/* Set "orlbkintp" M variable */
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_orlbkintp, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* ; Node Spanning Blocks - BEGIN */

	/* set keysize=^%imptp(fillid,"key_size") */
	YDB_COPY_STRING_TO_BUFF("key_size", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	keysize = atoi(value.buf_addr);
	value.len_used = sprintf(value.buf_addr, "%d", keysize);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_keysize, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* set recsize=^%imptp(fillid,"record_size") */
	YDB_COPY_STRING_TO_BUFF("record_size", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	recsize = atoi(value.buf_addr);
	value.len_used = sprintf(value.buf_addr, "%d", recsize);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_recsize, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* set span=+^%imptp(fillid,"gtm_test_spannode") */
	YDB_COPY_STRING_TO_BUFF("gtm_test_spannode", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	span = atoi(value.buf_addr);
	value.len_used = sprintf(value.buf_addr, "%d", span);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_span, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* ; Node Spanning Blocks - END */

	/* ; TRIGGERS - BEGIN */

	/* ; The triggers section MUST be the last update to ^%imptp during setup. Online Rollback tests use this as a marker to detect
	 * ; when ^%imptp has been rolled back.
	 */
	/* set trigger=^%imptp(fillid,"trigger"),ztrcmd="ztrigger ^lasti(fillid,jobno,loop)",ztr=0,dztrig=0 */
	YDB_COPY_STRING_TO_BUFF("trigger", &subscr[1]);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, &value);
	YDB_ASSERT(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	trigger = atoi(value.buf_addr);
	/* Set "trigger" M variable */
	value.len_used = sprintf(value.buf_addr, "%d", trigger);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_trigger, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	YDB_COPY_STRING_TO_BUFF("ztrigger ^lasti(fillid,jobno,loop)", &value);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_ztrcmd, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);
	ztr = 0;
	dztrig = 0;

	/* if trigger do */
	if (trigger)
	{
		/* . set trigname="triggernameforinsertsanddels" */
		YDB_COPY_STRING_TO_BUFF("triggernameforinsertsanddels", &value);
		status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_trigname, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);

		/* . set fulltrig="^unusedbyothersdummytrigger -commands=S -xecute=""do ^nothing"" -name="_trigname */
		YDB_COPY_STRING_TO_BUFF("^unusedbyothersdummytrigger -commands=S -xecute=\"do ^nothing\" -name=triggernameforinsertsanddels", &value);
		status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_fulltrig, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);

		/* . set ztr=(trigger#10)>1  ; ZTRigger command testing */
		ztr = ((trigger % 10) > 1);

		/* . set dztrig=(trigger>10) ; $ZTRIGger() function testing */
		dztrig = (trigger > 10);
	}
	value.len_used = sprintf(value.buf_addr, "%d", dztrig);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_dztrig, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* ; TRIGGERS -  END */

	/* set zwrcmd="zwr jobno,istp,tptype,tpnoiso,orlbkintp,dupset,skipreg,crash,gtcm,fillid,keysize,recsize,trigger" */
	/* write zwrcmd,! */
	/* xecute zwrcmd */
	printf("jobno=%d\n", jobno);
	printf("istp=%d\n", istp);
	printf("tptype=%s\n", tmpvalue.buf_addr);
	printf("tpnoiso=%d\n", tpnoiso);
	printf("orlbkintp=0\n");
	printf("dupset=%d\n", dupset);
	printf("skipreg=%d\n", skipreg);
	printf("crash=%d\n", crash);
	printf("gtcm=%d\n", gtcm);
	printf("fillid=%d\n", fillid);
	printf("keysize=%d\n", keysize);
	printf("recsize=%d\n", recsize);
	printf("trigger=%d\n", trigger);

	/* write "PID: ",$job,!,"In hex: ",$$FUNC^%DH($job),! */
	printf("PID: %d\nIn hex: 0x%x\n", process_id, process_id);
	fflush(stdout);	/* flush stdout as soon as efficiently possible */

	/* lock +^%imptp(fillid,"jsyncnt")  set ^%imptp(fillid,"jsyncnt")=^%imptp(fillid,"jsyncnt")+1  lock -^%imptp(fillid,"jsyncnt") */
	/* The "ydb_lock_incr_s" and "ydb_lock_decr_s" usages below are unnecessary since "ydb_incr_s" is atomic.
	 * But we want to test the SimpleAPI/SimpleThreadAPI lock functions and so have them here just like the M version of imptp.
	 */
	YDB_COPY_STRING_TO_BUFF("jsyncnt", &subscr[1]);
	status = ydb_lock_incr_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, &ygbl_pctimptp, 2, subscr);
	YDB_ASSERT(YDB_OK == status);
	rand = (int)(2 * drand48());
	valueptr = (0 == rand) ? &value : NULL;	/* Randomly test that "ydb_incr_s" is fine with a NULL "ret_value" parameter */
	status = ydb_incr_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr, NULL, valueptr);
	YDB_ASSERT(YDB_OK == status);
	status = ydb_lock_decr_st(YDB_NOTTP, NULL, &ygbl_pctimptp, 2, subscr);
	YDB_ASSERT(YDB_OK == status);

	/* ; lfence is used for the fence type of last segment of updates of *ndxarr at the end
	 * ; For non-tp and crash test meaningful application checking is very difficult
	 * ; So at the end of the iteration TP transaction is used
	 * ; For gtcm we cannot use TP at all, because it is not supported.
	 * ; We cannot do crash test for gtcm.
	 */
	/* set lfence=istp */
	/* if (istp=0)&(crash=1) set lfence=1	; TP fence */
	/* if gtcm=1 set lfence=0			; No fence */
	lfence = istp;
	if (!istp && crash)
		lfence = 1;
	if (gtcm)
		lfence = 0;
	/* Set "lfence" M variable */
	value.len_used = sprintf(value.buf_addr, "%d", lfence);
	status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_lfence, 0, NULL, &value);
	YDB_ASSERT(YDB_OK == status);

	/* if tpnoiso do tpnoiso^imptp */
	if (tpnoiso)
	{
		status = ydb_cip_t(YDB_NOTTP, NULL, &tpnoiso_cid); /* Use call-in for this as it contains VIEW commands which are not yet supported in SimpleAPI/SimpleThreadAPI */
		YDB_ASSERT(YDB_OK == status);
	}

	/* if dupset view "GVDUPSETNOOP":1 */
	if (dupset)
	{
		status = ydb_cip_t(YDB_NOTTP, NULL, &dupsetnoop_cid); /* Use call-in for this as it contains VIEW commands which are not yet supported in SimpleAPI/SimpleThreadAPI */
		YDB_ASSERT(YDB_OK == status);
	}

	/* set nroot=1
	 * for J=1:1:jobcnt set nroot=(nroot*root)#prime
	 */
	for (nroot = 1, i = 1; i <= jobcnt; i++)
		nroot = (nroot * root) % prime;

	/* ; imptp can be restarted at the saved value of lasti */

	/* set lasti=+$get(^lasti(fillid,jobno)) */
	subscr[1].len_used = sprintf(subscr[1].buf_addr, "%d", jobno);
	status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_lasti, 2, subscr, &value);
	if (YDB_ERR_GVUNDEF == status)
		lasti = 0;
	else
	{
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		lasti = atoi(value.buf_addr);
	}

	/* zwrite lasti */
	printf("lasti=%d\n", lasti);

	/* ; */
	/* ; Initially we have followings: */
	/* ; 	Job 1: I=w^0 */
	/* ; 	Job 2: I=w^1 */
	/* ; 	Job 3: I=w^2 */
	/* ; 	Job 4: I=w^3 */
	/* ; 	Job 5: I=w^4 */
	/* ;	nroot = w^5 (all job has same value) */
	/* set I=1 */
	/* for J=2:1:jobno  set I=(I*root)#prime */
	/* for J=1:1:lasti  set I=(I*nroot)#prime */
	/* ; */
	I = 1;
	for (J = 2; J <= jobno; J++)
		I = ((unsigned long long)I * root) % prime;
	for (J = 1; J <= lasti; J++)
		I = ((unsigned long long)I * nroot) % prime;

	/* write "Starting index:",lasti+1,! */
	printf("Starting index:%d\n", lasti + 1);
	fflush(stdout);	/* flush stdout as soon as possible after "printf" call */

	YDB_LITERAL_TO_BUFFER("*", &starvar);

	/* for loop=lasti+1:1:top do  quit:$get(^endloop(fillid),0) */
	for (loop = lasti + 1; loop <= top; loop++)
	{
		/* Set I and loop M variables (needed by "helper1" call-in code) */
		value.len_used = sprintf(value.buf_addr, "%d", I);
		status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_I, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.len_used = sprintf(value.buf_addr, "%d", loop);
		status = ydb_set_st(YDB_NOTTP, NULL, &ylcl_loop, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);

		/* ; Go to the sleep cycle if a ^pause is requested. Wait until ^resume is called
		 * do pauseifneeded^pauseimptp
		 * set subs=$$^ugenstr(I)		; I to subs  has one-to-one mapping
		 * set val=$$^ugenstr(loop)		; loop to val has one-to-one mapping
		 * set recpad=recsize-($$^dzlenproxy(val)-$length(val))				; padded record size minus UTF-8 bytes
		 * set recpad=$select((istp=2)&(recpad>800):800,1:recpad)			; ZTP uses the lower of the orig 800 or recpad
		 * set valMAX=$j(val,recpad)
		 * set valALT=$select(span>1:valMAX,1:val)
		 * set keypad=$select(istp=2:1,1:keysize-($$^dzlenproxy(subs)-$length(subs)))	; padded key size minus UTF-8 bytes. ZTP uses no padding
		 * set subsMAX=$j(subs,keypad)
		 * if $$^dzlenproxy(subsMAX)>keysize write $$^dzlenproxy(subsMAX),?4 zwr subs,I,loop
		 */
		status = ydb_cip_t(YDB_NOTTP, NULL, &helper1_cid);	/* Use call-in to implement the block of M code commented above */
		YDB_ASSERT(YDB_OK == status);

		/* Copy variable names to parameter array */
		parm_array[0] = crash;
		parm_array[1] = trigger;
		parm_array[2] = istp;
		parm_array[3] = fillid;
		parm_array[4] = loop;
		parm_array[5] = jobno;
		parm_array[6] = I;
		parm_array[7] = ztr;
		parm_array[8] = dztrig;

		/* Initialize variables subsMAX, val, valALT, valMAX, subs for use by later function calls ("tpfn_stage1", etc.) */
		status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_subsMAX, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		YDB_COPY_BUFF_TO_BUFF(&value, &ybuff_subsMAX);
		status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_val, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		YDB_COPY_BUFF_TO_BUFF(&value, &ybuff_val);
		status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_valALT, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		YDB_COPY_BUFF_TO_BUFF(&value, &ybuff_valALT);
		status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_valMAX, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		YDB_COPY_BUFF_TO_BUFF(&value, &ybuff_valMAX);
		status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_subs, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		YDB_COPY_BUFF_TO_BUFF(&value, &ybuff_subs);
		status = ydb_get_st(YDB_NOTTP, NULL, &ylcl_I, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		YDB_COPY_BUFF_TO_BUFF(&value, &ybuff_I);

		/* . ; Stage 1 */
		/* . if istp=1 tstart *:(serial:transaction=tptype) */
		/* Run a block of code as a TP or non-TP transaction based on "istp" variable */
		if (istp)
		{
			status = ydb_tp_st(YDB_NOTTP, NULL, &tpfn_stage1, parm_array, (const char *)ybuff_tptype.buf_addr, 1, &starvar);
			YDB_ASSERT(YDB_OK == status);
		} else
		{
			status = tpfn_stage1(YDB_NOTTP, NULL, parm_array);
			YDB_ASSERT(YDB_OK == status);
		}
		/* if istp=1 tcommit */

		/* . ; Stage 2 */

		/* . set rndm=$random(10) */
		/* . if (5>rndm)&(0=$tlevel)&trigger do  ; $ztrigger() operation 50% of the time: 10% del by name, 10% del, 80% add */
		/* . . set rndm=$random(10),trig=$select(0=rndm:"-"_fulltrig,1=rndm:"-"_trigname,1:"+"_fulltrig) */
		/* . . set ztrigstr="set ztrigret=$ztrigger(""item"",trig)"	; xecute needed so it compiles on non-trigger platforms */
		/* . . xecute ztrigstr */
		/* . . if (trig=("-"_trigname))&(ztrigret=0) set ztrigret=1	; trigger does not exist, ignore delete-by-name error */
		/* . . goto:'ztrigret ERROR */
		status = ydb_cip_t(YDB_NOTTP, NULL, &helper2_cid);	/* $ztrigger is anyways not supported in SimpleAPI/SimpleThreadAPI so use call-ins instead */
		YDB_ASSERT(YDB_OK == status);

		/* . set ^antp(fillid,subs)=val */
		/* subscr[0] already has <fillid> value in it */
		YDB_COPY_BUFF_TO_BUFF(&ybuff_subs, &subscr[1]);
		status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_antp, 2, subscr, &ybuff_val);
		YDB_ASSERT(YDB_OK == status);

		/* . if 'trigger do */
		if (!trigger)
		{
			/* . . set ^bntp(fillid,subs)=val */
			status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_bntp, 2, subscr, &ybuff_val);
			YDB_ASSERT(YDB_OK == status);

			/* . . set ^cntp(fillid,subs)=val */
			status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_cntp, 2, subscr, &ybuff_val);
			YDB_ASSERT(YDB_OK == status);
		}

		/* . . set ^dntp(fillid,subs)=valALT */
		status = ydb_set_st(YDB_NOTTP, NULL, &ygbl_dntp, 2, subscr, &ybuff_valALT);
		YDB_ASSERT(YDB_OK == status);

		/* . ; Stage 3 */
		/* . if istp=1 tstart ():(serial:transaction=tptype) */
		/* Run a block of code as a TP or non-TP transaction based on "istp" variable */
		if (istp)
		{
			status = ydb_tp_st(YDB_NOTTP, NULL, &tpfn_stage3, parm_array, (const char *)ybuff_tptype.buf_addr, 0, NULL);
			YDB_ASSERT(YDB_OK == status);
		} else
		{
			status = tpfn_stage3(YDB_NOTTP, NULL, parm_array);
			YDB_ASSERT(YDB_OK == status);
		}
		/* if istp=1 tcommit */

		/* . ; Stage 4 thru 11*/
		status = ydb_cip_t(YDB_NOTTP, NULL, &helper3_cid);
		YDB_ASSERT(YDB_OK == status);

		/* . ; Stage 4 */
		/* . for J=1:1:jobcnt D */
		/* . . set valj=valALT_J */
		/* . . ; */
		/* . . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp) */
		/* . . set ^arandom(fillid,subs,J)=valj */
		/* . . if 'trigger do */
		/* . . . set ^brandomv(fillid,subs,J)=valj */
		/* . . . set ^crandomva(fillid,subs,J)=valj */
		/* . . . set ^drandomvariable(fillid,subs,J)=valj */
		/* . . . set ^erandomvariableimptp(fillid,subs,J)=valj */
		/* . . . set ^frandomvariableinimptp(fillid,subs,J)=valj */
		/* . . . set ^grandomvariableinimptpfill(fillid,subs,J)=valj */
		/* . . . set ^hrandomvariableinimptpfilling(fillid,subs,J)=valj */
		/* . . . set ^irandomvariableinimptpfillprgrm(fillid,subs,J)=valj */
		/* . . do:dztrig ^imptpdztrig(1,istp<2) */
		/* . . if istp=1 tcommit */
		/* . . ; */
		/* . ; Stage 5 */
		/* . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp) */
		/* . do:dztrig ^imptpdztrig(2,istp<2) */
		/* . if ((istp=1)&(crash)) do */
		/* . . set rndm=$random(10) */
		/* . . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time */
		/* . . if rndm=2 if $TRESTART>2  hang $random(10)	; Just randomly hold crit for long time */
		/* . kill ^arandom(fillid,subs,1) */
		/* . if 'trigger do */
		/* . . kill ^brandomv(fillid,subs,1) */
		/* . . kill ^crandomva(fillid,subs,1) */
		/* . . kill ^drandomvariable(fillid,subs,1) */
		/* . . kill ^erandomvariableimptp(fillid,subs,1) */
		/* . . kill ^frandomvariableinimptp(fillid,subs,1) */
		/* . . kill ^grandomvariableinimptpfill(fillid,subs,1) */
		/* . . kill ^hrandomvariableinimptpfilling(fillid,subs,1) */
		/* . . kill ^irandomvariableinimptpfillprgrm(fillid,subs,1) */
		/* . do:dztrig ^imptpdztrig(1,istp<2) */
		/* . do:dztrig ^imptpdztrig(2,istp<2) */
		/* . if istp=1 tcommit */
		/* . ; Stage 6 */
		/* . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp) */
		/* . zkill ^jrandomvariableinimptpfillprogram(fillid,I) */
		/* . if 'trigger do */
		/* . . zkill ^jrandomvariableinimptpfillprogram(fillid,I,I) */
		/* . if istp=1 tcommit */
		/* . ; Stage 7 : delimited spanning nodes to be changed in Stage 10 */
		/* . ; At the end of ithis transaction, ^aspan=^espan and $tr(^aspan," ","")=^bspan */
		/* . ; Partial completion due to crash results in: 1. ^aspan is defined and ^[be]span are undef */
		/* . ;				 		2. ^aspan=^espan and ^bspan is undef */
		/* . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp) */
		/* . ; divide up valMAX into a "|" delimited string with the delimiter placed at every 7th space char */
		/* . set piecesize=7 */
		/* . set valPIECE=valMAX */
		/* . set totalpieces=($length(valPIECE)/piecesize)+1 */
		/* . for i=1:1:totalpieces set:($extract(valPIECE,(piecesize*i))=" ") $extract(valPIECE,(piecesize*i))="|" ; $extract beyond $length returns a null character */
		/* . set totalpieces=$length(valPIECE,"|") */
		/* . set ^aspan(fillid,I)=valPIECE */
		/* . if 'trigger do */
		/* . . set ^espan(fillid,I)=$get(^aspan(fillid,I)) */
		/* . . set ^bspan(fillid,I)=$tr($get(^aspan(fillid,I))," ","") */
		/* . if istp=1 tcommit */
		/* . ; Stage 8 */
		/* . kill ^arandom(fillid,subs,1)	; This results nothing */
		/* . kill ^antp(fillid,subs) */
		/* . if 'trigger do */
		/* . . kill ^bntp(fillid,subs) */
		/* . . zkill ^brandomv(fillid,subs,1)	; This results nothing */
		/* . . zkill ^cntp(fillid,subs) */
		/* . . zkill ^dntp(fillid,subs) */
		/* . kill ^bntp(fillid,subsMAX) */
		/* . if istp=1 set ^dummy(fillid)=$h		; To test duplicate sets for TP. */
		/* . ; Stage 9 */
		/* . ; $incr on ^cntloop and ^cntseq exercize contention in CREG (regions > 3) or DEFAULT (regions <= 3) */
		/* . set flag=$random(2) */
		/* . if flag=1,lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp) */
		/* . set cntloop=$incr(^cntloop(fillid)) */
		/* . set cntseq=$incr(^cntseq(fillid),(13+jobcnt)) */
		/* . if flag=1,lfence=1 tcommit */
		/* . ; Stage 10 : More SET $piece */
		/* . ; At the end of ithis transaction, $tr(^aspan," ","")=^bspan and $p(^aspan,"|",targetpiece)=$p(^espan,"|",targetpiece) */
		/* . ; NOTE that ZKILL ^espan means that the SET $PIECE of ^espan will only create pieces up to the target piece */
		/* . ; Partial completion due to crash results in: 1. ^espan is undef and $tr(^aspan," ","")=^bspan */
		/* . ;				   		2. ^espan is undef and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X") */
		/* . ;				   		3. $p(^aspan,"|",targetpiece)=$tr($p(^espan,"|",targetpiece) and $p(^aspan,"|",targetpiece)=$tr($p(^bspan,"|",targetpiece)," ","X") */
		/* . if istp=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp>0 ifneeded^orlbkresume(istp) */
		/* . set targetpiece=(loop#(totalpieces)) */
		/* . set subpiece=$tr($piece($get(^aspan(fillid,I)),"|",targetpiece)," ","X") */
		/* . zkill ^espan(fillid,I) */
		/* . set $piece(^aspan(fillid,I),"|",targetpiece)=subpiece */
		/* . if 'trigger do */
		/* . . set $piece(^espan(fillid,I),"|",targetpiece)=subpiece */
		/* . . set $piece(^bspan(fillid,I),"|",targetpiece)=subpiece */
		/* . if istp=1 tcommit */
		/* . ; Stage 11 */
		/* . if lfence=1 tstart (orlbkcycle):(serial:transaction=tptype) do:orlbkintp=2 ifneeded^orlbkresume(istp) */
		/* . do:dztrig ^imptpdztrig(1,istp<2) */
		/* . xecute:ztr "set $ztwormhole=I ztrigger ^andxarr(fillid,jobno,loop) set $ztwormhole=""""" */
		/* . set ^andxarr(fillid,jobno,loop)=I */
		/* . if 'trigger do */
		/* . . set ^bndxarr(fillid,jobno,loop)=I */
		/* . . set ^cndxarr(fillid,jobno,loop)=I */
		/* . . set ^dndxarr(fillid,jobno,loop)=I */
		/* . . set ^endxarr(fillid,jobno,loop)=I */
		/* . . set ^fndxarr(fillid,jobno,loop)=I */
		/* . . set ^gndxarr(fillid,jobno,loop)=I */
		/* . . set ^hndxarr(fillid,jobno,loop)=I */
		/* . . set ^indxarr(fillid,jobno,loop)=I */
		/* . if istp=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop */
		/* . if lfence=1 tcommit */

		/* . set I=(I*nroot)#prime */
		I = ((unsigned long long)I * nroot) % prime;

		/* quit:$get(^endloop(fillid),0) */
		status = ydb_get_st(YDB_NOTTP, NULL, &ygbl_endloop, 1, subscr, &value);
		if (YDB_ERR_GVUNDEF == status)
			continue;
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		if (atoi(value.buf_addr))
			break;

	}	/* ; End For Loop */

	/* write "End index:",loop,! */
	printf("End index:%d\n", loop);

	/* write "Job completion successful",! */
	printf("Job completion successful\n");

	/* write "End Time : ",$ZD($H,"DD-MON-YEAR 24:60:SS"),! */
	value.len_used = sprintf(value.buf_addr, "End Time : %s", get_curtime());
	YDB_ASSERT(value.len_used < value.len_alloc);
	printf("%s\n", value.buf_addr);

	fflush(stdout);	/* flush stdout as soon as efficiently possible */

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

/* In the TP callback functions, note that it is possible for a SimpleThreadAPI call to return with YDB_ERR_CALLINAFTERXIT.
 * This indicates the process has started exit handling and is waiting for the TP worker threads to terminate.
 * Therefore return from the TP callback function right away in that case.
 */
int	tpfn_stage1(uint64_t tptoken, ydb_buffer_t *errstr, int *parm_array)
{
	int	crash, trigger, istp, fillid, loop, jobno, I, ztr;
	int	rndm, dollar_trestart;
	int	status;

	/* First copy down parmeter array into variables */
	crash = parm_array[0];
	trigger = parm_array[1];
	istp = parm_array[2];
	fillid = parm_array[3];
	loop = parm_array[4];
	jobno = parm_array[5];
	I = parm_array[6];
	ztr = parm_array[7];

	/* . set ^arandom(fillid,subsMAX)=val */
	subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", fillid);
	YDB_COPY_BUFF_TO_BUFF(&ybuff_subsMAX, &subscr[1]);
	status = ydb_set_st(tptoken, errstr, &ygbl_arandom, 2, subscr, &ybuff_val);
	if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
		return status;
	YDB_ASSERT(YDB_OK == status);

	/* . if ((istp=1)&(crash)) do */
	if (istp & crash)
	{
		/* . . set rndm=$r(10) */
		rndm = (int)(10 * drand48());

		/* . . if rndm=1 if $TRESTART>2  do noop^imptp	; Just randomly hold crit for long time */
		status = ydb_get_st(tptoken, errstr, &yisv_trestart, 0, NULL, &value);
		YDB_ASSERT(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		dollar_trestart = atoi(value.buf_addr);
		if (2 < dollar_trestart)
		{
			if (1 == rndm)
			{
				status = ydb_cip_t(tptoken, errstr, &noop_cid);
				/* Unlike SimpleAPI/SimpleThreadAPI which only returns YDB_ERR_* codes (all negative numbers),
				 * "ydb_cip_t" can return ERR_TPRETRY (a positive number). An easy way to check that is to
				 * take negation of YDB_ERR_TPRETRY (which is == ERR_TPRETRY) and compare that against
				 * the return value. In that case, return YDB_TP_RESTART from this function as that
				 * is what the caller ("ydb_tp_s") knows to handle.
				 */
				if (-YDB_ERR_TPRETRY == status)
					return YDB_TP_RESTART;
				YDB_ASSERT(YDB_OK == status);
			}
			/* . . if rndm=2 if $TRESTART>2  h $r(10)		; Just randomly hold crit for long time */
			if (2 == rndm)
			{
				rndm = (int)(10 * drand48());
				sleep(rndm);
			}
		}
		/* . . if $TRESTART set ^zdummy($TRESTART)=jobno	; In case of restart cause different TP transaction flow */
		if (dollar_trestart)
		{
			YDB_COPY_BUFF_TO_BUFF(&value, &subscr[2]);
			value.len_used = sprintf(value.buf_addr, "%d", jobno);
			status = ydb_set_st(tptoken, errstr, &ygbl_zdummy, 1, &subscr[2], &value);
			if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
				return status;
			YDB_ASSERT(YDB_OK == status);
		}
	}
	/* . set ^brandomv(fillid,subsMAX)=valALT */
	status = ydb_set_st(tptoken, errstr, &ygbl_brandomv, 2, subscr, &ybuff_valALT);
	if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
		return status;
	YDB_ASSERT(YDB_OK == status);

	/* . if 'trigger do */
	if (!trigger)
	{
		/* . . set ^crandomva(fillid,subsMAX)=valALT */
		status = ydb_set_st(tptoken, errstr, &ygbl_crandomva, 2, subscr, &ybuff_valALT);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);
	}

	/* . set ^drandomvariable(fillid,subs)=valALT */
	YDB_COPY_BUFF_TO_BUFF(&ybuff_subs, &subscr[1]);
	status = ydb_set_st(tptoken, errstr, &ygbl_drandomvariable, 2, subscr, &ybuff_valALT);
	if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
		return status;
	YDB_ASSERT(YDB_OK == status);

	/* . if 'trigger do */
	if (!trigger)
	{
		/* . . set ^erandomvariableimptp(fillid,subs)=valALT */
		status = ydb_set_st(tptoken, errstr, &ygbl_erandomvariableimptp, 2, subscr, &ybuff_valALT);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);

		/* . . set ^frandomvariableinimptp(fillid,subs)=valALT */
		status = ydb_set_st(tptoken, errstr, &ygbl_frandomvariableinimptp, 2, subscr, &ybuff_valALT);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);
	}

	/* . set ^grandomvariableinimptpfill(fillid,subs)=val */
	status = ydb_set_st(tptoken, errstr, &ygbl_grandomvariableinimptpfill, 2, subscr, &ybuff_val);
	if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
		return status;
	YDB_ASSERT(YDB_OK == status);

	/* . if 'trigger do */
	if (!trigger)
	{
		/* . . set ^hrandomvariableinimptpfilling(fillid,subs)=val */
		status = ydb_set_st(tptoken, errstr, &ygbl_hrandomvariableinimptpfilling, 2, subscr, &ybuff_val);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);

		/* . . set ^irandomvariableinimptpfillprgrm(fillid,subs)=val */
		status = ydb_set_st(tptoken, errstr, &ygbl_irandomvariableinimptpfillprgrm, 2, subscr, &ybuff_val);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);
	} else
	{
		/* . if trigger xecute ztwormstr	; fill in $ztwormhole for below update that requires "subs" */
		status = ydb_cip_t(tptoken, errstr, &ztwormstr_cid);
		if (-YDB_ERR_TPRETRY == status)
			return YDB_TP_RESTART;
		YDB_ASSERT(YDB_OK == status);
	}

	/* . set ^jrandomvariableinimptpfillprogram(fillid,I)=val */
	YDB_COPY_BUFF_TO_BUFF(&ybuff_I, &subscr[1]);
	status = ydb_set_st(tptoken, errstr, &ygbl_jrandomvariableinimptpfillprogram, 2, subscr, &ybuff_val);
	if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
		return status;
	YDB_ASSERT(YDB_OK == status);

	/* . if 'trigger do */
	if (!trigger)
	{
		/* . . set ^jrandomvariableinimptpfillprogram(fillid,I,I)=val */
		YDB_COPY_BUFF_TO_BUFF(&ybuff_I, &subscr[2]);
		status = ydb_set_st(tptoken, errstr, &ygbl_jrandomvariableinimptpfillprogram, 3, subscr, &ybuff_val);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);

		/* . . set ^jrandomvariableinimptpfillprogram(fillid,I,I,subs)=val */
		YDB_COPY_BUFF_TO_BUFF(&ybuff_subs, &subscr[3]);
		status = ydb_set_st(tptoken, errstr, &ygbl_jrandomvariableinimptpfillprogram, 4, subscr, &ybuff_val);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);
	}

	if (istp)
	{
		/* . if istp'=0 xecute:ztr ztrcmd set ^lasti(fillid,jobno)=loop */
		if (ztr)
		{
			status = ydb_cip_t(tptoken, errstr, &ztrcmd_cid);
			if (-YDB_ERR_TPRETRY == status)
				return YDB_TP_RESTART;
			YDB_ASSERT(YDB_OK == status);
		}
		subscr[1].len_used = sprintf(subscr[1].buf_addr, "%d", jobno);
		value.len_used = sprintf(value.buf_addr, "%d", loop);
		status = ydb_set_st(tptoken, errstr, &ygbl_lasti, 2, subscr, &value);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);
	}
	return YDB_OK;
}

int	tpfn_stage3(uint64_t tptoken, ydb_buffer_t *errstr, int *parm_array)
{
	int	dztrig, istp;
	int	status;

	/* First copy down parmeter array into variables */
	istp = parm_array[2];
	dztrig = parm_array[8];

	/* . do:dztrig ^imptpdztrig(2,istp<2) */
	if (dztrig)
	{
		status = ydb_cip_t(tptoken, errstr, &imptpdztrig_cid);
		if (-YDB_ERR_TPRETRY == status)
			return YDB_TP_RESTART;
		YDB_ASSERT(YDB_OK == status);
	}

	/* . set ^entp(fillid,subs)=val */
	/* subscr[0] already has <fillid> value in it */
	YDB_COPY_BUFF_TO_BUFF(&ybuff_subs, &subscr[1]);
	status = ydb_set_st(tptoken, errstr, &ygbl_entp, 2, subscr, &ybuff_val);
	if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
		return status;
	YDB_ASSERT(YDB_OK == status);

	/* . if 'trigger do */
	if (!trigger)
	{
		/* . . set ^fntp(fillid,subs)=val */
		status = ydb_set_st(tptoken, errstr, &ygbl_fntp, 2, subscr, &ybuff_val);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);
	} else
	{
		/* . if trigger do */
		/* . . set ^fntp(fillid,subs)=$extract(^fntp(fillid,subs),1,$length(^fntp(fillid,subs))-$length("suffix")) */
		status = ydb_get_st(tptoken, errstr, &ygbl_fntp, 2, subscr, &value);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);
		if (6 <= value.len_used)
			value.len_used -= 6;	/* 6 is $length("suffix") */
		else
		{
			YDB_ASSERT(istp);
			return YDB_TP_RESTART;	/* This is a restartable situation (TP isolation violated). Signal a restart. */
		}
		status = ydb_set_st(tptoken, errstr, &ygbl_fntp, 2, subscr, &value);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);
	}
	/* . set ^gntp(fillid,subsMAX)=valMAX */
	YDB_COPY_BUFF_TO_BUFF(&ybuff_subsMAX, &subscr[1]);
	status = ydb_set_st(tptoken, errstr, &ygbl_gntp, 2, subscr, &ybuff_valMAX);
	if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
		return status;
	YDB_ASSERT(YDB_OK == status);

	/* . if 'trigger do */
	if (!trigger)
	{
		/* . . set ^hntp(fillid,subsMAX)=valMAX */
		status = ydb_set_st(tptoken, errstr, &ygbl_hntp, 2, subscr, &ybuff_valMAX);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
		YDB_ASSERT(YDB_OK == status);

		/* . . set ^intp(fillid,subsMAX)=valMAX */
		status = ydb_set_st(tptoken, errstr, &ygbl_intp, 2, subscr, &ybuff_valMAX);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;

		/* . . set ^bntp(fillid,subsMAX)=valMAX */
		status = ydb_set_st(tptoken, errstr, &ygbl_bntp, 2, subscr, &ybuff_valMAX);
		if ((YDB_TP_RESTART == status) || (YDB_ERR_CALLINAFTERXIT == status))
			return status;
	}
	return YDB_OK;
}
