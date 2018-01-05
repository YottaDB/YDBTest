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

/* Use SIGILL below to generate a core when an assertion fails */
#define assert(x) ((x) ? 1 : (fprintf(stderr, "Assert failed at %s line %d : %s\n", __FILE__, __LINE__, #x), kill(process_id, SIGILL)))

#define	NTPJ		1
#define	TPRJ		5
#define	TPCJ		10
#define	NCHILDREN	TPCJ

typedef enum
{
	NTP = 0,
	TPR = 1,
	TPC = 2
} tpflag_t;

/* Global variables (set in parent, but visible to children too) */
int		child;
int		outfd, errfd, newfd;
ydb_buffer_t	value;
char		valuebuff[64];
size_t		nbytes;

/* Declare all ydb_buffer_t structures corresponding to M local variables (ylcl_ prefix) */
ydb_buffer_t	ylcl_iterate, ylcl_localinstance;

/* Declare all ydb_buffer_t structures corresponding to M global variables (ygbl_ prefix) */
ydb_buffer_t	ygbl_permit, ygbl_instance, ygbl_PID;


/* Helper function prototypes */
int	child_func(void);

/* This is a C program using simpleAPI to implement "do run^concurr(times)" */

int main(int argc, char *argv[])
{
	int		status, stat[NCHILDREN + 1], ret[NCHILDREN + 1];
	pid_t		child_pid[NCHILDREN + 1];
	pid_t		process_id;

	process_id = getpid();

	/* set iterate=times (where times is specified in argv[1]) : run+1^concurr */
	YDB_STRLIT_TO_BUFFER(&ylcl_iterate, "iterate");
	YDB_STR_TO_BUFFER(&value, argv[1]);
	status = ydb_set_s(&ylcl_iterate, 0, NULL, &value);
	assert(YDB_OK == status);

	value.buf_addr = valuebuff;
	value.len_alloc = sizeof(valuebuff);

	/* Make stress.mje0 the stdout : stress^stress */
	outfd = creat("stress.mjo0", 0666);
	assert(-1 != outfd);
	newfd = dup2(outfd, 1);
	assert(1 == newfd);

	/* Write parent process PID to stress.mjo0 : stress^stress */
	value.len_used = sprintf(value.buf_addr, "PID: %d\n", process_id);
	nbytes = write(newfd, value.buf_addr, value.len_used);
	assert(nbytes == value.len_used);

	/* Make stress.mje0 the stderr : stress^stress */
	errfd = creat("stress.mje0", 0666);
	assert(-1 != errfd);
	newfd = dup2(errfd, 2);
	assert(2 == newfd);

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
			return child_func();	/* this is the child */
		}
	}
	for (child = 1; child <= NCHILDREN; child++)
	{
		ret[child] = waitpid(child_pid[child], &stat[child], 0);
		assert(-1 != ret[child]);
	}
	return YDB_OK;
}

int	child_func(void)
{
	char		outfile[64], errfile[64];
	ydb_buffer_t	jobno, subscr[2];
	tpflag_t	tpflag;
	char		*tpflagstr[] = {"NTP", "TPR", "TPC"};
	int		loop, status, childcnt, iterate;
	pid_t		process_id;

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
	nbytes = write(newfd, value.buf_addr, value.len_used);
	assert(nbytes == value.len_used);

	/* Make stress.mje1, stress.mje2 etc. the stderr */
	sprintf(errfile, "stress.mje%d", child);
	errfd = creat(errfile, 0666);
	assert(-1 != errfd);
	newfd = dup2(errfd, 1);
	assert(1 == newfd);

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
	YDB_STRLIT_TO_BUFFER(&jobno, "jobno");
	value.len_used = sprintf(value.buf_addr, "%d", child);
	status = ydb_set_s(&jobno, 0, NULL, &value);
	assert(YDB_OK == status);

	/* SET ^PID(jobno,localinstance)=$j : job^stress */
	subscr[0] = jobno;
	subscr[1] = ylcl_localinstance;
	value.len_used = sprintf(value.buf_addr, "%d", (int)process_id);
	status = ydb_set_s(&ygbl_PID, 2, subscr, &value);
	assert(YDB_OK == status);

	/* NARSTODO: lock +^permit($j) : job^stress */

	iterate = atoi(ylcl_iterate.buf_addr);

	/* F loop=1:1:iterate DO : job^stress */
	for (loop = 1; loop < iterate; loop++)
	{
		/* write "iteration number : ",loop,! : job^stress */
		value.len_used = sprintf(value.buf_addr, "iteration number : %d", loop);
		nbytes = write(newfd, value.buf_addr, value.len_used);
		assert(nbytes == value.len_used);
	}

	return YDB_OK;
}
