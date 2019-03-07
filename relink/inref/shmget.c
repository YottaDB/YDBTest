/****************************************************************
 *								*
 * Copyright 2014 Fidelity Information Services, Inc		*
 *								*
 * Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include <dlfcn.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdlib.h>
#include <errno.h>

/* This script can be compiled as a library and LD_PRELOADed in order to control the behavior of shmget() calls.
 * Specifically, $gtm_test_shmget_count can be set to a positive integer that would cause the consecutive shmget()
 * invocation by that index to fail with ENOMEM.
 */
int shmget(key_t key, size_t size, int shmflg)
{
	int		(*shmget_fptr)(key_t, size_t, int);
	int		index;
	char		*index_val;
	static int	inv_count = 0;

	inv_count++;
	index_val = getenv("gtm_test_shmget_count");
	if (NULL != index_val)
		index = atoi(index_val);
	else
		index = 0;

	shmget_fptr = (int (*)(key_t, size_t, int))dlsym(RTLD_NEXT, "shmget");

	if (inv_count == index)
	{
		errno = ENOMEM;
		return -1;
	} else
		return shmget_fptr(key, size, shmflg);
}
