/****************************************************************
 *								*
 *	Copyright 2014 Fidelity Information Services, Inc	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#define _GNU_SOURCE
#include <dlfcn.h>
#include <sys/types.h>
#include <sys/shm.h>
#include <stdlib.h>
#include <errno.h>

/* This script can be compiled as a library and LD_PRELOADed in order to control the behavior of shmat() calls.
 * Specifically, $gtm_test_shmat_count can be set to a positive integer that would cause the consecutive shmat()
 * invocation by that index to fail with ENOMEM.
 */
void *shmat(int shmid, const void *shmaddr, int shmflg)
{
	void		*(*shmat_fptr)(int, const void *, int);
	int		index;
	char		*index_val;
	static int	inv_count = 0;

	inv_count++;
	index_val = getenv("gtm_test_shmat_count");
	if (NULL != index_val)
		index = atoi(index_val);
	else
		index = 0;

	shmat_fptr = (void *(*)(int, const void *, int))dlsym(RTLD_NEXT, "shmat");

	if (inv_count == index)
	{
		errno = ENOMEM;
		return (void *)-1;
	} else
		return shmat_fptr(shmid, shmaddr, shmflg);
}
