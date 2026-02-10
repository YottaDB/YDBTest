/****************************************************************
 *								*
 * Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Set signal mask to block SIGUSR1 to test that YottaDB's signal initialization clears the signal mask properly */
int main(int argc, char **argv)
{
	sigset_t	signals;

	printf("Add SIGUSR1 to the signal mask\n");
	fflush(stdout);
	if (-1 == sigemptyset(&signals))
		printf("Error: sigemptyset() - %s\n", strerror(errno));
	if (-1 == sigaddset(&signals, SIGUSR1))
		printf("Error: sigaddset() - %s\n", strerror(errno));
	if (-1 == sigprocmask(SIG_BLOCK, &signals, NULL))
		printf("Error: sigprocmask() - %s\n", strerror(errno));
	if (-1 == execvp(argv[1], &argv[1]))
		printf("Error: execvp() - %s\n", strerror(errno));
	return EXIT_FAILURE;
}
