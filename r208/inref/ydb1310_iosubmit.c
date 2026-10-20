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
#include <stdarg.h>
#include <stddef.h>
#include <sys/syscall.h>

/* This file is compiled as a library and LD_PRELOADed to make every io_submit() system call fail with EAGAIN.
 * YottaDB issues io_submit() through syscall() (see sr_unix/aio_shim.c), so it is syscall() that is replaced here.
 * Every other system call number is passed through to the real syscall() unchanged.
 */
long syscall(long number, ...)
{
	static long	(*real_syscall)(long, ...);
	va_list		ap;
	long		arg[6];
	int		i;

	if (SYS_io_submit == number)
	{
		errno = EAGAIN;
		return -1;
	}
	if (NULL == real_syscall)
		real_syscall = (long (*)(long, ...))dlsym(RTLD_NEXT, "syscall");
	/* syscall() takes at most 6 arguments after the number, and the kernel ignores the ones a system call does not
	 * take, so forwarding 6 for every call is safe (glibc's own syscall() does the same).
	 */
	va_start(ap, number);
	for (i = 0; i < 6; i++)
		arg[i] = va_arg(ap, long);
	va_end(ap);
	return real_syscall(number, arg[0], arg[1], arg[2], arg[3], arg[4], arg[5]);
}
