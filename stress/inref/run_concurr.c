/****************************************************************
 *								*
 * Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include "libyottadb.h"	/* for ydb_* macros/prototypes/typedefs */

#include <stdio.h>	/* for "printf" */
#include <string.h>	/* for "strlen" */

#include <sys/types.h>	/* needed for "kill" in assert */
#include <signal.h>	/* needed for "kill" in assert */
#include <unistd.h>	/* needed for "getpid" and "sleep" */
#include <fcntl.h>	/* for "creat" prototype */
#include <sys/wait.h>	/* for "waitpid" prototype */
#include <stdlib.h>	/* for "atoi" prototype */
#include <time.h>	/* for "localtime" prototype */

#include "libydberrors.h"	/* for YDB_ERR_* error codes */

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(process_id, SIGILL)))

#define	NTPJ		1
#define	TPRJ		5
#define	TPCJ		10
#define	NCHILDREN	TPCJ

#define	YDB_COPY_BUFF_TO_BUFF(SRC, DST)					\
{									\
	assert((SRC)->len_used <= (DST)->len_alloc);			\
	memcpy((DST)->buf_addr, (SRC)->buf_addr, (SRC)->len_used);	\
	(DST)->len_used = (SRC)->len_used;				\
}

#define YDB_BUFF_T_IS_IDENTICAL(vcorr, vcomp)									\
	((vcorr->len_used == vcomp->len_used) && !memcmp(vcorr->buf_addr, vcomp->buf_addr, vcomp->len_used))

typedef enum
{
	NTP = 0,
	TPR = 1,
	TPC = 2
} tpflag_t;

typedef enum
{
	SET = 0,
	KILL= 1,
	VER = 2
} act_t;

char timeString[9];  /* space for "HH:MM:SS\0" */

/* Global variables (set in parent, but visible to children too) */
int		child;
int		outfd, errfd, newfd;
ydb_buffer_t	value, pidvalue;
char		valuebuff[64], pidvaluebuff[64], subscrbuff[YDB_MAX_SUBS + 1][64];
ydb_buffer_t	subscr[YDB_MAX_SUBS + 1];
size_t		nbytes;
pid_t		process_id;

/* Declare all ydb_buffer_t structures corresponding to M local variables (ylcl_ prefix) */
ydb_buffer_t	ylcl_iterate, ylcl_localinstance;
ydb_buffer_t	ylcl_ERR;

/* Declare all ydb_buffer_t structures corresponding to M global variables (ygbl_ prefix) */
ydb_buffer_t	ygbl_permit, ygbl_instance, ygbl_PID, ygbl_lasti;

/* Declare all M variables that don't need ylcl_ or ygbl_ prefixes */
tpflag_t	tpflag;

/* Helper function prototypes */
int	m_job_stress(void);
int	job_stress_tpfn();
int	m_randfill(act_t act, int pno, int iter);
int	m_filling_randfill(act_t act, int prime, int root, int iter);
void	m_EXAM_randfill(char *pos, ydb_buffer_t *vcorr, ydb_buffer_t *vcomp);
char	*get_curtime(void);

/* This is a C program using simpleAPI to implement "do run^concurr(times)" */

/* Implements M entryref run^concurr */
int main(int argc, char *argv[])
{
	int		i, status, stat[NCHILDREN + 1], ret[NCHILDREN + 1];
	pid_t		child_pid[NCHILDREN + 1];

	process_id = getpid();

	/* set iterate=times (where times is specified in argv[1]) : run+1^concurr */
	YDB_STRLIT_TO_BUFFER(&ylcl_iterate, "iterate");
	YDB_STR_TO_BUFFER(&value, argv[1]);
	status = ydb_set_s(&ylcl_iterate, 0, NULL, &value);
	assert(YDB_OK == status);

	value.buf_addr = valuebuff;
	value.len_alloc = sizeof(valuebuff);
	pidvalue.buf_addr = pidvaluebuff;
	pidvalue.len_alloc = sizeof(pidvaluebuff);

	for (i = 0; i < YDB_MAX_SUBS + 1; i++)
	{
		subscr[i].buf_addr = subscrbuff[i];
		subscr[i].len_alloc = sizeof(subscrbuff[i]);
	}
	/* Make stress.mje0 the stdout : stress^stress */
	outfd = creat("stress.mjo0", 0666);
	assert(-1 != outfd);
	newfd = dup2(outfd, 1);
	assert(1 == newfd);

	/* Write parent process PID to stress.mjo0 : stress^stress */
	value.len_used = sprintf(value.buf_addr, "PID: %d\n", process_id);
	nbytes = write(outfd, value.buf_addr, value.len_used);
	assert(nbytes == value.len_used);
	assert(nbytes < value.len_alloc);

	/* Make stress.mje0 the stderr : stress^stress */
	errfd = creat("stress.mje0", 0666);
	assert(-1 != errfd);
	newfd = dup2(errfd, 2);
	assert(2 == newfd);
	newfd = 1;

	/* SET localinstance=^instance : stress^stress */
	YDB_STRLIT_TO_BUFFER(&ygbl_instance, "^instance");
	status = ydb_get_s(&ygbl_instance, 0, NULL, &value);
	assert(YDB_OK == status);
	YDB_STRLIT_TO_BUFFER(&ylcl_localinstance, "localinstance");
	status = ydb_set_s(&ylcl_localinstance, 0, NULL, &value);
	assert(YDB_OK == status);

	/* Initialize ydb_buffer_t structures for M global variables that we will use */
	YDB_STRLIT_TO_BUFFER(&ygbl_permit, "^permit");
	YDB_STRLIT_TO_BUFFER(&ygbl_PID, "^PID");

	/* NARSTODO:
	 *
	 * lock +^permit
	 * Wait until each child has set ^PID(jobno,localinstance)
	 * lock -^permit
	 */

	/* Spawn NCHILDREN children */
	for (child = 1; child <= NCHILDREN; child++)
	{
		child_pid[child] = fork();
		assert(0 <= child_pid[child]);
		if (0 == child_pid[child])
		{
			status = ydb_child_init(NULL);	/* needed in child pid right after a fork() */
			assert(YDB_OK == status);
			return m_job_stress();	/* this is the child */
		}
	}
	for (child = 1; child <= NCHILDREN; child++)
	{
		ret[child] = waitpid(child_pid[child], &stat[child], 0);
		assert(-1 != ret[child]);
	}
	return YDB_OK;
}

/* Implements M entryref job^stress */
int	m_job_stress(void)
{
	char		outfile[64], errfile[64];
	ydb_buffer_t	ylcl_jobno;
	char		*tpflagstr[] = {"NTP", "TPR", "TPC"};
	int		loop, status, childcnt, iterate;
	ydb_buffer_t	ylcl_efill, ylcl_ffill, ylcl_gfill, ylcl_hfill, ylcl_loop;

	process_id = getpid();

	if (NTPJ >= child)
		tpflag = NTP;
	else if (TPRJ >= child)
		tpflag = TPR;
	else
		tpflag = TPC;

	/* Make stress.mjo1, stress.mjo2 etc. the stdout : job^stress */
	sprintf(outfile, "stress.mjo%d", child);
	outfd = creat(outfile, 0666);
	assert(-1 != outfd);
	newfd = dup2(outfd, 1);
	assert(1 == newfd);

	/* Write child process PID to stress.mjo1, stress.mjo2 etc. : job^stress */
	value.len_used = sprintf(value.buf_addr, "PID: %d : TYPE:%s\n", process_id, tpflagstr[tpflag]);
	nbytes = write(outfd, value.buf_addr, value.len_used);
	assert(nbytes == value.len_used);
	assert(nbytes < value.len_alloc);

	/* Make stress.mje1, stress.mje2 etc. the stderr */
	sprintf(errfile, "stress.mje%d", child);
	errfd = creat(errfile, 0666);
	assert(-1 != errfd);
	newfd = dup2(errfd, 2);
	assert(2 == newfd);

	/* Wait for all children to reach this point before continuing forward : job^stress */
	status = ydb_incr_s(&ygbl_permit, 0, NULL, NULL, &value);
	assert(YDB_OK == status);
	for ( ; ; )
	{
		status = ydb_get_s(&ygbl_permit, 0, NULL, &value);
		assert(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		childcnt = atoi(value.buf_addr);
		if (NCHILDREN == childcnt)
			break;
		sleep(1);
	}

	/* SET jobno=child# : job^stress */
	YDB_STRLIT_TO_BUFFER(&ylcl_jobno, "jobno");
	value.len_used = sprintf(value.buf_addr, "%d", child);
	status = ydb_set_s(&ylcl_jobno, 0, NULL, &value);
	assert(YDB_OK == status);

	/* SET ^PID(jobno,localinstance)=$j : job^stress */
	status = ydb_get_s(&ylcl_jobno, 0, NULL, &subscr[0]);
	assert(YDB_OK == status);
	status = ydb_get_s(&ylcl_localinstance, 0, NULL, &subscr[1]);
	assert(YDB_OK == status);
	pidvalue.len_used = sprintf(pidvalue.buf_addr, "%d", (int)process_id);
	status = ydb_set_s(&ygbl_PID, 2, subscr, &pidvalue);
	assert(YDB_OK == status);

	/* NARSTODO: lock +^permit($j) : job^stress */

	status = ydb_get_s(&ylcl_iterate, 0, NULL, &value);
	assert(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	iterate = atoi(value.buf_addr);

	/* Define needed M local variables */
	YDB_STRLIT_TO_BUFFER(&ylcl_efill, "efill");
	YDB_STRLIT_TO_BUFFER(&ylcl_ffill, "ffill");
	YDB_STRLIT_TO_BUFFER(&ylcl_gfill, "gfill");
	YDB_STRLIT_TO_BUFFER(&ylcl_hfill, "hfill");
	YDB_STRLIT_TO_BUFFER(&ylcl_loop, "loop");

	/* Define needed M global variables */
	YDB_STRLIT_TO_BUFFER(&ygbl_lasti, "^lasti");

	/* NEW loop */
	status = ydb_delete_s(&ylcl_loop, 0, NULL, YDB_DEL_TREE);
	assert(YDB_OK == status);

	/* F loop=1:1:iterate DO : job^stress */
	for (loop = 1; loop < iterate; loop++)
	{
		/* write "iteration number : ",loop,! : job^stress */
		value.len_used = sprintf(value.buf_addr, "iteration number : %d\n", loop);
		nbytes = write(outfd, value.buf_addr, value.len_used);
		assert(nbytes == value.len_used);
		assert(nbytes < value.len_alloc);
		/* write "Wating for the parent to release lock : ",$zdate($H,"24:60:SS"),! */
		value.len_used = sprintf(value.buf_addr, "Waiting for the parent to release lock : %s\n", get_curtime());
		nbytes = write(outfd, value.buf_addr, value.len_used);
		assert(nbytes == value.len_used);
		assert(nbytes < value.len_alloc);

		/* NEW efill,ffill,gfill,hfill */
		status = ydb_delete_s(&ylcl_efill, 0, NULL, YDB_DEL_TREE);
		assert(YDB_OK == status);
		status = ydb_delete_s(&ylcl_ffill, 0, NULL, YDB_DEL_TREE);
		assert(YDB_OK == status);
		status = ydb_delete_s(&ylcl_gfill, 0, NULL, YDB_DEL_TREE);
		assert(YDB_OK == status);
		status = ydb_delete_s(&ylcl_hfill, 0, NULL, YDB_DEL_TREE);
		assert(YDB_OK == status);

		/* SET loop=... (set M local variable loop to C local variable loop) */
		value.len_used = sprintf(value.buf_addr, "%d", (int)loop);
		status = ydb_set_s(&ylcl_loop, 0, NULL, &value);
		assert(YDB_OK == status);
		/* SET (efill(loop),ffill(loop),gfill(loop),hfill(loop))=loop */
		status = ydb_get_s(&ylcl_loop, 0, NULL, &subscr[0]);
		assert(YDB_OK == status);
		status = ydb_set_s(&ylcl_efill, 1, subscr, &subscr[0]);
		assert(YDB_OK == status);
		status = ydb_set_s(&ylcl_ffill, 1, subscr, &subscr[0]);
		assert(YDB_OK == status);
		status = ydb_set_s(&ylcl_gfill, 1, subscr, &subscr[0]);
		assert(YDB_OK == status);
		status = ydb_set_s(&ylcl_hfill, 1, subscr, &subscr[0]);
		assert(YDB_OK == status);

		/* if tpflag'="NTP" TSTART (efill,ffill,gfill,hfill):(serial:transaction="BA") */
		if (NTP != tpflag)
		{
			status = ydb_tp_s(&job_stress_tpfn, &loop, "BA", "efill,ffill,gfill,hfill");
			assert((YDB_OK == status) || (YDB_TP_ROLLBACK == status));
		} else
		{
			status = job_stress_tpfn(&loop);
			assert(YDB_OK == status);
		}
		/* S ^lasti(jobno,localinstance)=loop */
		status = ydb_get_s(&ylcl_jobno, 0, NULL, &subscr[0]);
		assert(YDB_OK == status);
		status = ydb_get_s(&ylcl_localinstance, 0, NULL, &subscr[1]);
		assert(YDB_OK == status);
		status = ydb_get_s(&ylcl_loop, 0, NULL, &value);
		assert(YDB_OK == status);
		status = ydb_set_s(&ygbl_lasti, 2, subscr, &value);
		assert(YDB_OK == status);
	}
	/* w "Successful : ",$zdate($H,"24:60:SS"),! */
	value.len_used = sprintf(value.buf_addr, "Successful : %s\n", get_curtime());
	nbytes = write(outfd, value.buf_addr, value.len_used);
	assert(nbytes == value.len_used);
	assert(nbytes < value.len_alloc);

	return YDB_OK;
}

int	job_stress_tpfn(int *loop_ptr)
{
	int		loop, pno, trestart, tlevel;
	ydb_buffer_t	yisv_trestart, yisv_tlevel;
	int		status;

	loop = *loop_ptr;
	pno = (2 * loop) % 10 + 1;	/* loop+loop#10+1 */
	m_randfill(KILL, pno, loop);
	m_randfill(SET, pno, loop);
	m_randfill(VER, pno, loop);

	/* if $TRESTART WRITE "TRESTART = ",$TRESTART," For Loop=",loop," TLEVEL=",$TLEVEL,! */
	YDB_STRLIT_TO_BUFFER(&yisv_trestart, "$trestart");
	status = ydb_get_s(&yisv_trestart, 0, NULL, &value);
	assert(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	trestart = atoi(value.buf_addr);

	if (trestart)
	{
		assert(NTP != tpflag);
		YDB_STRLIT_TO_BUFFER(&yisv_tlevel, "$tlevel");
		status = ydb_get_s(&yisv_tlevel, 0, NULL, &value);
		assert(YDB_OK == status);
		value.buf_addr[value.len_used] = '\0';
		tlevel = atoi(value.buf_addr);

		value.len_used = sprintf(value.buf_addr, "TRESTART = %d For Loop=%d TLEVEL=%d\n", trestart, loop, tlevel);
		nbytes = write(outfd, value.buf_addr, value.len_used);
		assert(nbytes == value.len_used);
		assert(nbytes < value.len_alloc);
	}
	/* if tpflag="TPR" TROLLBACK */
	if (TPR == tpflag)
		return YDB_TP_ROLLBACK;

	/* if tpflag="TPC" TCOMMIT */
	if (TPC == tpflag)
		return YDB_OK;

	return YDB_OK;
}

/* Implements M entryref ^randfill */
int	m_randfill(act_t act, int pno, int iter)
{
	ydb_buffer_t	ygbl_root, ygbl_prime;
	int		prime, root;
	int		status;

	/* Get root(pno) */
	YDB_STRLIT_TO_BUFFER(&ygbl_root, "^root");
	subscr[0].len_used = sprintf(subscr[0].buf_addr, "%d", pno);
	status = ydb_get_s(&ygbl_root, 1, subscr, &value);
	if (YDB_TP_RESTART == status)
		return status;
	assert(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	root = atoi(value.buf_addr);

	/* Get ^prime */
	YDB_STRLIT_TO_BUFFER(&ygbl_prime, "^prime");
	status = ydb_get_s(&ygbl_prime, 0, NULL, &value);
	if (YDB_TP_RESTART == status)
		return status;
	assert(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	prime = atoi(value.buf_addr);

	return m_filling_randfill(act, prime, root, iter);
}

/* Implements M entryref filling^randfill */
int	m_filling_randfill(act_t act, int prime, int root, int iter)
{
	ydb_buffer_t	ylcl_MAXERR, ylcl_ndx;
	ydb_buffer_t	ygbl_cust, ygbl_afill, ygbl_b, ygbl_cfill, ygbl_dfill, ygbl_e, ygbl_efill, ygbl_ffill;
	ydb_buffer_t	ygbl_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb, ygbl_pct1;
	ydb_buffer_t	ylcl_obj;
	ydb_buffer_t	tmp1, tmp2;
	char		tmp1buff[64], tmp2buff[64], errstrbuff[64];
	int		ERR, MAXERR;
	int		i, j, ndx, status, tmp, len;

	tmp1.buf_addr = tmp1buff;
	tmp1.len_alloc = sizeof(tmp1buff);
	tmp2.buf_addr = tmp2buff;
	tmp2.len_alloc = sizeof(tmp2buff);

	/* set ERR=0 */
	YDB_STRLIT_TO_BUFFER(&ylcl_ERR, "ERR");
	value.len_used = sprintf(value.buf_addr, "%d", 0);
	status = ydb_set_s(&ylcl_ERR, 0, NULL, &value);
	assert(YDB_OK == status);

	/* set MAXERR=10 */
	YDB_STRLIT_TO_BUFFER(&ylcl_MAXERR, "MAXERR");
	value.len_used = sprintf(value.buf_addr, "%d", 10);
	status = ydb_set_s(&ylcl_MAXERR, 0, NULL, &value);
	assert(YDB_OK == status);

	/* set ndx=1 */
	YDB_STRLIT_TO_BUFFER(&ylcl_ndx, "ndx");
	ndx = 1;
	value.len_used = sprintf(value.buf_addr, "%d", ndx);
	status = ydb_set_s(&ylcl_ndx, 0, NULL, &value);
	assert(YDB_OK == status);

	YDB_STRLIT_TO_BUFFER(&ylcl_obj, "obj");

	YDB_STRLIT_TO_BUFFER(&ygbl_cust, "^cust");
	YDB_STRLIT_TO_BUFFER(&ygbl_afill, "^afill");
	YDB_STRLIT_TO_BUFFER(&ygbl_b, "^b");
	YDB_STRLIT_TO_BUFFER(&ygbl_cfill, "^cfill");
	YDB_STRLIT_TO_BUFFER(&ygbl_dfill, "^dfill");
	YDB_STRLIT_TO_BUFFER(&ygbl_e, "^e");
	YDB_STRLIT_TO_BUFFER(&ygbl_efill, "^efill");
	YDB_STRLIT_TO_BUFFER(&ygbl_ffill, "^ffill");
	YDB_STRLIT_TO_BUFFER(&ygbl_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb, "^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb");
	YDB_STRLIT_TO_BUFFER(&ygbl_pct1, "^pct1");

	switch(act)
	{
	case SET:
		for (i = 0; i < prime - 1; i++)
		{
			/* SET obj=^cust(ndx,^instance)*/
			status = ydb_get_s(&ylcl_ndx, 0, NULL, &subscr[0]);
			assert(YDB_OK == status);
			status = ydb_get_s(&ygbl_instance, 0, NULL, &subscr[1]);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			status = ydb_get_s(&ygbl_cust, 2, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			status = ydb_set_s(&ylcl_obj, 0, NULL, &subscr[1]);
			assert(YDB_OK == status);

			/* SET ^afill(ndx,obj,iter)=ndx*/
			/* subscr[0] already holds "ndx" */
			/* subscr[1] already holds "obj" */
			subscr[2].len_used = sprintf(subscr[2].buf_addr, "%d", iter);
			status = ydb_set_s(&ygbl_afill, 3, subscr, &subscr[0]);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET ^e(ndx,obj,iter)=ndx*/
			status = ydb_set_s(&ygbl_e, 3, subscr, &subscr[0]);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET ^cfill(ndx,obj,iter)=ndx*/
			status = ydb_set_s(&ygbl_cfill, 3, subscr, &subscr[0]);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET ^dfill(ndx,obj,iter)=ndx*/
			status = ydb_set_s(&ygbl_dfill, 3, subscr, &subscr[0]);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET ^ffill(ndx,obj,iter)=ndx*/
			status = ydb_set_s(&ygbl_ffill, 3, subscr, &subscr[0]);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET efill(ndx)=$GET(^efill(ndx,obj,^PID(jobno,^instance),iter))*/
			/* SET efill(ndx)=efill(ndx)+prime*/
			/* SET ^efill(ndx,obj,^PID(jobno,^instance),iter)=efill(ndx)*/
			YDB_COPY_BUFF_TO_BUFF(&subscr[2], &subscr[3]);	/* copy over "iter" from 3rd into 4th subscript */
			YDB_COPY_BUFF_TO_BUFF(&pidvalue, &subscr[2]);	/* copy over "$j" into 3rd subscript */
			status = ydb_get_s(&ygbl_efill, 4, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			if (YDB_ERR_GVUNDEF == status)
				tmp = 0;
			else
			{
				assert(YDB_OK == status);
				value.buf_addr[value.len_used] = '\0';
				tmp = atoi(value.buf_addr);
			}
			tmp += prime;
			value.len_used = sprintf(value.buf_addr, "%d", tmp);
			status = ydb_set_s(&ygbl_efill, 4, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET %1(ndx)=$GET(^%1(ndx,obj,^PID(jobno,^instance),iter))*/
			/* SET %1(ndx)=%1(ndx)+prime*/
			/* SET ^%1(ndx,obj,^PID(jobno,^instance),iter)=%1(ndx)*/
			status = ydb_get_s(&ygbl_pct1, 4, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			if (YDB_ERR_GVUNDEF == status)
				tmp = 0;
			else
			{
				assert(YDB_OK == status);
				value.buf_addr[value.len_used] = '\0';
				tmp = atoi(value.buf_addr);
			}
			tmp += prime;
			value.len_used = sprintf(value.buf_addr, "%d", tmp);
			status = ydb_set_s(&ygbl_pct1, 4, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET b(ndx)=$GET(^b(ndx,obj,^PID(jobno,^instance),iter))*/
			/* SET b(ndx)=b(ndx)+prime*/
			/* SET ^b(ndx,obj,^PID(jobno,^instance),iter)=b(ndx)*/
			status = ydb_get_s(&ygbl_b, 4, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			if (YDB_ERR_GVUNDEF == status)
				tmp = 0;
			else
			{
				assert(YDB_OK == status);
				value.buf_addr[value.len_used] = '\0';
				tmp = atoi(value.buf_addr);
			}
			tmp += prime;
			value.len_used = sprintf(value.buf_addr, "%d", tmp);
			status = ydb_set_s(&ygbl_b, 4, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx)=$GET(^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx,obj,^PID(jobno,^instance),iter))*/
			/* SET bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx)=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx)+prime*/
			/* SET ^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx,obj,^PID(jobno,^instance),iter)=bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx)*/
			status = ydb_get_s(&ygbl_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb, 4, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			if (YDB_ERR_GVUNDEF == status)
				tmp = 0;
			else
			{
				assert(YDB_OK == status);
				value.buf_addr[value.len_used] = '\0';
				tmp = atoi(value.buf_addr);
			}
			tmp += prime;
			value.len_used = sprintf(value.buf_addr, "%d", tmp);
			status = ydb_set_s(&ygbl_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb, 4, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET ndx=(ndx*root)#prime*/
			ndx = (ndx * root) % prime;
			value.len_used = sprintf(value.buf_addr, "%d", ndx);
			status = ydb_set_s(&ylcl_ndx, 0, NULL, &value);
			assert(YDB_OK == status);

			/* QUIT:ERR>MAXERR */
			status = ydb_get_s(&ylcl_ERR, 0, NULL, &value);
			assert(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			ERR = atoi(value.buf_addr);
			status = ydb_get_s(&ylcl_MAXERR, 0, NULL, &value);
			assert(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			MAXERR = atoi(value.buf_addr);
			if (ERR > MAXERR)
				break;
		}
		break;
	case VER:
		for (i = 0; i < prime - 1; i++)
		{
			/* SET obj=^cust(ndx,^instance)*/
			status = ydb_get_s(&ylcl_ndx, 0, NULL, &subscr[0]);
			assert(YDB_OK == status);
			YDB_COPY_BUFF_TO_BUFF(&subscr[0], &tmp1);	/* take a copy for later use */
			status = ydb_get_s(&ygbl_instance, 0, NULL, &subscr[1]);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			status = ydb_get_s(&ygbl_cust, 2, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			status = ydb_set_s(&ylcl_obj, 0, NULL, &subscr[1]);
			assert(YDB_OK == status);

			/*  do EXAM("^afill("_ndx_","_obj_","_iter_")",ndx,^afill(ndx,obj,iter)) */
			/* subscr[0] already holds "ndx" */
			/* subscr[1] already holds "obj" */
			subscr[2].len_used = sprintf(subscr[2].buf_addr, "%d", iter);
			status = ydb_get_s(&ygbl_afill, 3, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			for (j = 0; j < 3; j++)
				subscr[j].buf_addr[subscr[j].len_used] = '\0';
			len = sprintf(errstrbuff, "^afill(%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr);
			assert(len < sizeof(errstrbuff));
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/*  do EXAM("^e("_ndx_","_obj_","_iter_")",ndx,^e(ndx,obj,iter)) */
			status = ydb_get_s(&ygbl_e, 3, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			len = sprintf(errstrbuff, "^e(%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr);
			assert(len < sizeof(errstrbuff));
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/* do EXAM("^cfill("_ndx_","_obj_","_iter_")",ndx,^cfill(ndx,obj,iter)) */
			status = ydb_get_s(&ygbl_cfill, 3, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			len = sprintf(errstrbuff, "^cfill(%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr);
			assert(len < sizeof(errstrbuff));
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/* do EXAM("^dfill("_ndx_","_obj_","_iter_")",ndx,^dfill(ndx,obj,iter)) */
			status = ydb_get_s(&ygbl_dfill, 3, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			len = sprintf(errstrbuff, "^dfill(%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr);
			assert(len < sizeof(errstrbuff));
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/* do EXAM("^ffill("_ndx_","_obj_","_iter_")",ndx,^ffill(ndx,obj,iter)) */
			status = ydb_get_s(&ygbl_ffill, 3, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			len = sprintf(errstrbuff, "^ffill(%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr);
			assert(len < sizeof(errstrbuff));
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/* do EXAM("^efill("_ndx_","_obj_","_^PID(jobno,^instance)_","_iter_")",prime,^efill(ndx,obj,^PID(jobno,^instance),iter)) */
			YDB_COPY_BUFF_TO_BUFF(&subscr[2], &subscr[3]);	/* copy over "iter" from 3rd into 4th subscript */
			YDB_COPY_BUFF_TO_BUFF(&pidvalue, &subscr[2]);	/* copy over "$j" into 3rd subscript */
			status = ydb_get_s(&ygbl_efill, 4, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			for (j = 2; j < 4; j++)
				subscr[j].buf_addr[subscr[j].len_used] = '\0';
			len = sprintf(errstrbuff, "^efill(%s,%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr, subscr[3].buf_addr);
			assert(len < sizeof(errstrbuff));
			tmp1.len_used = sprintf(tmp1.buf_addr, "%d", prime);
			tmp1.buf_addr[tmp1.len_used] = '\0';
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/* do EXAM("^%1("_ndx_","_obj_","_^PID(jobno,^instance)_","_iter_")",prime,^%1(ndx,obj,^PID(jobno,^instance),iter)) */
			status = ydb_get_s(&ygbl_pct1, 4, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			len = sprintf(errstrbuff, "^%%1(%s,%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr, subscr[3].buf_addr);
			assert(len < sizeof(errstrbuff));
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/* do EXAM("^b("_ndx_","_obj_","_^PID(jobno,^instance)_","_iter_")",prime,^b(ndx,obj,^PID(jobno,^instance),iter)) */
			status = ydb_get_s(&ygbl_b, 4, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			len = sprintf(errstrbuff, "^b(%s,%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr, subscr[3].buf_addr);
			assert(len < sizeof(errstrbuff));
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/* do EXAM("^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb("_ndx_","_obj_","_^PID(jobno,^instance)_","_iter_")",prime,^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx,obj,^PID(jobno,^instance),iter)) */
			status = ydb_get_s(&ygbl_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb, 4, subscr, &tmp2);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			len = sprintf(errstrbuff, "^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(%s,%s,%s,%s)", subscr[0].buf_addr, subscr[1].buf_addr, subscr[2].buf_addr, subscr[3].buf_addr);
			assert(len < sizeof(errstrbuff));
			m_EXAM_randfill(errstrbuff, &tmp1, &tmp2);

			/* SET ndx=(ndx*root)#prime*/
			ndx = (ndx * root) % prime;
			value.len_used = sprintf(value.buf_addr, "%d", ndx);
			status = ydb_set_s(&ylcl_ndx, 0, NULL, &value);
			assert(YDB_OK == status);

			/* QUIT:ERR>MAXERR */
			status = ydb_get_s(&ylcl_ERR, 0, NULL, &value);
			assert(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			ERR = atoi(value.buf_addr);
			status = ydb_get_s(&ylcl_MAXERR, 0, NULL, &value);
			assert(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			MAXERR = atoi(value.buf_addr);
			if (ERR > MAXERR)
				break;
		}
		break;
	case KILL:
		for (i = 0; i < prime - 1; i++)
		{
			/* SET obj=^cust(ndx,^instance)*/
			status = ydb_get_s(&ylcl_ndx, 0, NULL, &subscr[0]);
			assert(YDB_OK == status);
			status = ydb_get_s(&ygbl_instance, 0, NULL, &subscr[1]);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			status = ydb_get_s(&ygbl_cust, 2, subscr, &value);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);
			status = ydb_set_s(&ylcl_obj, 0, NULL, &subscr[1]);
			assert(YDB_OK == status);

			/* KILL ^afill(ndx,obj,iter) */
			/* subscr[0] already holds "ndx" */
			/* subscr[1] already holds "obj" */
			subscr[2].len_used = sprintf(subscr[2].buf_addr, "%d", iter);
			status = ydb_delete_s(&ygbl_afill, 3, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* KILL ^e(ndx,obj,iter) */
			status = ydb_delete_s(&ygbl_e, 3, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* KILL ^cfill(ndx,obj,iter) */
			status = ydb_delete_s(&ygbl_cfill, 3, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* KILL ^dfill(ndx,obj,iter) */
			status = ydb_delete_s(&ygbl_dfill, 3, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* KILL ^ffill(ndx,obj,iter) */
			status = ydb_delete_s(&ygbl_ffill, 3, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* KILL ^efill(ndx,obj,^PID(jobno,^instance),iter) */
			YDB_COPY_BUFF_TO_BUFF(&subscr[2], &subscr[3]);	/* copy over "iter" from 3rd into 4th subscript */
			YDB_COPY_BUFF_TO_BUFF(&pidvalue, &subscr[2]);	/* copy over "$j" into 3rd subscript */
			status = ydb_delete_s(&ygbl_efill, 4, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* KILL ^%1(ndx,obj,^PID(jobno,^instance),iter)) */
			status = ydb_delete_s(&ygbl_pct1, 4, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* KILL ^b(ndx,obj,^PID(jobno,^instance),iter) */
			status = ydb_delete_s(&ygbl_b, 4, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* KILL ^bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb(ndx,obj,^PID(jobno,^instance),iter) */
			status = ydb_delete_s(&ygbl_bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb, 4, subscr, YDB_DEL_TREE);
			if (YDB_TP_RESTART == status)
				return status;
			assert(YDB_OK == status);

			/* SET ndx=(ndx*root)#prime*/
			ndx = (ndx * root) % prime;
			value.len_used = sprintf(value.buf_addr, "%d", ndx);
			status = ydb_set_s(&ylcl_ndx, 0, NULL, &value);
			assert(YDB_OK == status);

			/* QUIT:ERR>MAXERR */
			status = ydb_get_s(&ylcl_ERR, 0, NULL, &value);
			assert(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			ERR = atoi(value.buf_addr);
			status = ydb_get_s(&ylcl_MAXERR, 0, NULL, &value);
			assert(YDB_OK == status);
			value.buf_addr[value.len_used] = '\0';
			MAXERR = atoi(value.buf_addr);
			if (ERR > MAXERR)
				break;
		}
		break;
	default:
		assert(FALSE);
		break;
	}
	/* NARSTODO: i ERR'=0 w act," FAIL",! */
	status = ydb_get_s(&ylcl_ERR, 0, NULL, &value);
	assert(YDB_OK == status);
	value.buf_addr[value.len_used] = '\0';
	ERR = atoi(value.buf_addr);
	if (0 != ERR)
	{
		value.len_used = sprintf(value.buf_addr, "%s FAIL\n", ((SET == act) ? "set" : ((KILL == act) ? "kill" : "ver")));
		nbytes = write(outfd, value.buf_addr, value.len_used);
		assert(nbytes == value.len_used);
		assert(nbytes < value.len_alloc);
	}
	return YDB_OK;
}

/* Implements M entryref EXAM^randfill */
void	m_EXAM_randfill(char *pos, ydb_buffer_t *vcorr, ydb_buffer_t *vcomp)
{
	int	status;

	/* i vcorr=vcomp  q */
	if (YDB_BUFF_T_IS_IDENTICAL(vcorr, vcomp))
		return;

	/* w " ** FAIL verifying global ",pos,! */
	value.len_used = sprintf(value.buf_addr, " ** FAIL verifying global %s\n", pos);
	nbytes = write(outfd, value.buf_addr, value.len_used);
	assert(nbytes == value.len_used);
	assert(nbytes < value.len_alloc);

	/* w ?10,"CORRECT  = ",vcorr,! */
	vcorr->buf_addr[vcorr->len_used] = '\0';
	value.len_used = sprintf(value.buf_addr, "	CORRECT = %s\n", vcorr->buf_addr);
	nbytes = write(outfd, value.buf_addr, value.len_used);
	assert(nbytes == value.len_used);
	assert(nbytes < value.len_alloc);

	/* w ?10,"COMPUTED = ",vcomp,! */
	vcomp->buf_addr[vcomp->len_used] = '\0';
	value.len_used = sprintf(value.buf_addr, "	COMPUTED = %s\n", vcomp->buf_addr);
	nbytes = write(outfd, value.buf_addr, value.len_used);
	assert(nbytes == value.len_used);
	assert(nbytes < value.len_alloc);

	/* SET ERR=ERR+1 */
	status = ydb_incr_s(&ylcl_ERR, 0, NULL, NULL, &value);
	assert(YDB_OK == status);

	/* QUIT */
	return;
}

/* Returns current time in global variable "timeString" */
char *get_curtime()
{
	time_t current_time;
	struct tm * time_info;

	time(&current_time);
	time_info = localtime(&current_time);

	strftime(timeString, sizeof(timeString), "%H:%M:%S", time_info);
	return timeString;
}
