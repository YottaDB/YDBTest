/****************************************************************
 *								*
 * Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	*
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

/* This routine is a utility routine for the v63014/gtm9331 test. Its purpose is to immediately replace the standard
 * SIGALRM handler with one of our own. The routine returns when either we've received a SIGALRM signal (and ignored
 * it) or if the number of seconds specified by the input argument have expired.
 */

gtm_int_t signalDisable()
{
	struct sigaction	resetSIGALRM;

	/* Set up our SIGALRM intercept */
	memset(&resetSIGALRM, 0, sizeof(resetSIGALRM));
	sigemptyset(&resetSIGALRM.sa_mask);
	resetSIGALRM.sa_handler = SIG_IGN;
	sigaction(SIGALRM, &resetSIGALRM, (void *)0);
	return 0;
}
