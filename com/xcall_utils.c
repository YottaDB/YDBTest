/****************************************************************
 *								*
 * Copyright (c) 2015 Fidelity National Information 		*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include <errno.h>

#include <sys/time.h>
#include <sys/resource.h>

#include "gtmxc_types.h"

/*
 * Set the virtual memory limit for the current process.
 *
 * Arguments: limit - value to set the memory limit to, in KB.
 *
 * Returns: 0 on success; -1 otherwise.
 */
gtm_status_t set_rlimit(int argc, gtm_int_t limit, gtm_int_t *err_num)
{
        struct rlimit rlim;

	if (2 != argc)
		return (gtm_status_t)-argc;
        rlim.rlim_cur = limit * 1024;
        rlim.rlim_max = RLIM_INFINITY;
	*err_num = (-1 == setrlimit(RLIMIT_AS, &rlim)) ? (gtm_int_t)errno : 0;
	return (gtm_status_t)*err_num;
}
