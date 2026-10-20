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
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <stddef.h>
#include <unistd.h>

/* This file is compiled as a library and LD_PRELOADed into MUPIP REPLICATE -RECEIVER -START to make the receiver
 * server unable to fork the update process. The receiver server calls setsid() as it starts, so it is the only
 * process here that is a session leader. Every fork() it makes fails with EAGAIN. A fork() by any other process
 * (including the MUPIP that starts the receiver server) is passed through to the real fork().
 */
pid_t fork(void)
{
	static pid_t	(*real_fork)(void);

	if (getsid(0) == getpid())
	{
		errno = EAGAIN;
		return -1;
	}
	if (NULL == real_fork)
		real_fork = (pid_t (*)(void))dlsym(RTLD_NEXT, "fork");
	return real_fork();
}
