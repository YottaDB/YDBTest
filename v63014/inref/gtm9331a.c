/****************************************************************
 *								*
 * Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include "gtmxc_types.h"

#define DEBUG 1
#ifdef DEBUG
#  define DEBUG_ONLY(X) X
#else
#  define DEBUG_ONLY(X)
#endif
#define DPRINT(...) printf(__VA_ARGS__)

/* This routine is a utility routine for the v63014/gtm9331 test. Its purpose is to immediately replace the standard
 * SIGALRM handler with one of our own. The routine returns when either we've received a SIGALRM signal (and ignored
 * it) or if the number of seconds specified by the input argument have expired.
 *
 * Note: This routine is written using GT.M datatypes as this is a GT.M issue that was fixed and it can be useful to run
 * the test against GT.M versions.
 */
int sigPopped;
void ignoreSig(int sig);

gtm_int_t signalWait(gtm_uint_t argcnt, gtm_uint_t seconds)
{
	struct sigaction	resetSIGALRM, prevSIGALRM;
	int			sig, rc;

	sigPopped = 0;
	/* Set up our SIGALRM intercept */
	memset(&resetSIGALRM, 0, sizeof(resetSIGALRM));
	sigemptyset(&resetSIGALRM.sa_mask);
	resetSIGALRM.sa_handler = ignoreSig;
	sigaction(SIGALRM, &resetSIGALRM, &prevSIGALRM);
	DEBUG_ONLY(DPRINT("signalWait: Handler reset - starting sleep for max %d seconds\n", seconds));
	/* Now nap until the duration passes or we get a signal (don't care which) */
	sleep(seconds);
	DEBUG_ONLY(DPRINT("signalWait: Sleep complete - sig caught flag: %d\n",sigPopped));
	/* Restore signal handler before we return */
	sigaction(SIGALRM, &prevSIGALRM, NULL);
	fflush(stdout);
	return sigPopped;		/* Return indicator of whether signal popped or not */
}

/* Routine to catch an incoming SIGALRM from some GT.M/YottaDB origination (HANG, $ZTIMEOUT, etc) which we ignore but
 * which does enable us to return to the user after restoring the handler. This will verify that the remediation added
 * in V6.3-014 correctly allows this missing interrupt to be "found".
 */
void ignoreSig(int sig)
{
	DEBUG_ONLY(DPRINT("ignoreSig: Signal popped - in handler\n"));
	sigPopped = 1;		/* Note this popped */
}
