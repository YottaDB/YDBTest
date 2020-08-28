/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
/* C program to implement a Go test from a user in C instead so we can see how fatal signals behave under the original
 * signal handling methods. This test installs a replacement signal handler for SIGSEGV before it starts (so that handler
 * is also driven when the SIGSEGV occurs) that will unwind the handler allowing it to effect the return to the engine AFTER
 * the exit handler has been driven. This test is making sure we get a CALLINAFTERXIT error. This test also drives ydb_exit()
 * via an atexit() call so when the process exits, ydb_exit() is called. Verify it does not cause a hang.
 */

/* Build with: gcc -Wall -o ydb632 ydb632.c -Wl,-rpath,$ydb_dist -I$ydb_dist -L$ydb_dist -lyottadb -lelf -lncurses -lm -ldl -lc -lpthread -lrt
 */

#include "libyottadb.h"		/* For macros, prototypes, and typedefs */
#include "libydberrors.h"	/* For YDB_ERR_* error definitions */

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <setjmp.h>

/* File scope vars */
jmp_buf		unwind_ctx;	/* Allows us to unwind SIGSEGV */
int		segv_seen = FALSE;

/* Macros */
#define	YDB_COPY_BUFF_TO_BUFF(SRC, DST)				\
{								\
	int	copy_done;					\
								\
	YDB_COPY_BUFFER_TO_BUFFER(SRC, DST, copy_done);		\
	YDB_ASSERT(copy_done);					\
}

#define CHECK_ERRORS(CMD, RC, ERRSTRP, EXIT)								\
{													\
	if (YDB_OK != (RC))										\
	{												\
		if (0 != (ERRSTRP)->len_used)								\
			printf("** Error from %s (rc=%d): %.*s\n", CMD, RC, (ERRSTRP)->len_used,	\
			       (ERRSTRP)->buf_addr);							\
		else											\
			printf("** Error return code from %s: %d\n", CMD, RC);				\
		if (EXIT)										\
		{											\
			printf("** Exiting due to errors\n");						\
			exit(-1);									\
		}											\
	} else												\
		printf("%s completed successfully\n", CMD);						\
}

/* Our handler for SIGSEGV - just roll it back and provide an indication it happened */
void sigsegv_handler(int sig, siginfo_t *info, void *context)
{
	segv_seen = TRUE;
	longjmp(unwind_ctx, -1);
}

/* Our TP transaction routine (aka TP callback routine) */
int tpcallback1(uint64_t tptoken, ydb_buffer_t *errstr, void *parm)
{
	ydb_buffer_t	varname, varvalue;
	char		*nullderef, x;
	int		rc;

	rc = setjmp(unwind_ctx);
	printf("tpcallback1: Entered\n");
	if (0 != rc)
	{	/* A sigsegv occurred and was unwound. Tell the engine to proceed with its commit though
		 * we don't actually expect this to occur - we expect a CALLINAFTERXIT error as we exit
		 * the transaction.
		 */
		if (segv_seen)
			printf("tpcallback1: SIGSEGV seen - returning\n");
		else
			printf("tpcallback1: SIGSEGV **NOT** seen - returning\n");
		fflush(stdout);
		return YDB_OK;
	}
	/* First to a small update to initialize the engine */
	YDB_LITERAL_TO_BUFFER("^SomeVar", &varname);
	YDB_LITERAL_TO_BUFFER("some value", &varvalue);
	rc = ydb_set_st(tptoken, errstr, &varname, 0, NULL, &varvalue);
	CHECK_ERRORS("ydb_set_st()", rc, errstr, TRUE);
	/* Now let's cause a SIGSEGV by deferencing a NULL pointer */
	nullderef = NULL;
	x = *nullderef;
	printf("char: %c", x); /* To please compiler ("using" the x variable) */
	/* If we are here, the null deref worked (known to happen on some systems with addressable low memory). */
	/* Warn about it and leave */
	printf("** We made it through NULL deref - need different test\n");
	_exit(1);
}

/* Main routine */
int main(int argc, char *argv[])
{
	ydb_buffer_t		errstr;
	struct sigaction	sigsegv_action;
	int			rc;

	atexit((void (*)(void))ydb_exit);		/* Run ydb_exit() when the process exits */
	YDB_MALLOC_BUFFER(&errstr, YDB_MAX_ERRORMSG);
	/* Setup our version of interrupt handler before initialize YDB */
	memset(&sigsegv_action, 0, sizeof(sigsegv_action));
	sigemptyset(&sigsegv_action.sa_mask);
	sigsegv_action.sa_flags = SA_SIGINFO;
	sigsegv_action.sa_sigaction = sigsegv_handler;
	sigaction(SIGSEGV, &sigsegv_action, NULL);
	/* Now start our TP transaction */
	rc = ydb_tp_st(YDB_NOTTP, &errstr, &tpcallback1, NULL, NULL, 0, NULL);
	CHECK_ERRORS("ydb_tp_st()", rc, &errstr, FALSE);
	printf("Main terminating - driving ydb_exit()\n");
	fflush(stdout);
}
