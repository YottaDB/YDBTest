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
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
/* With _FILE_OFFSET_BITS=64, the headers turn pread() into pread64(), and the two definitions below would collide.
 * off_t is 64 bits on every platform YottaDB supports, so leaving it undefined changes nothing else.
 */
#undef _FILE_OFFSET_BITS
#include <dlfcn.h>
#include <errno.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <unistd.h>

/* This file is compiled as a library and LD_PRELOADed into MUPIP JOURNAL -RECOVER -BACKWARD.
 *
 * pthread_create() : the third consecutive call with the same start routine (MUPIP creates one worker thread per region,
 *	all with the same start routine) sends SIGTERM to the process and fails with EAGAIN, once. MUPIP blocks SIGTERM
 *	while it creates its worker threads, so the signal stays pending until MUPIP handles the failure, while the two
 *	worker threads it already created are running.
 * pread()/pread64() : every call from a thread other than the main one sleeps READ_DELAY_USEC first, so that those two
 *	worker threads are still reading their journal files when MUPIP handles the failure.
 */
#define FAIL_AT		3
#define READ_DELAY_USEC	2000

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine)(void *), void *arg)
{
	static int	(*real_pthread_create)(pthread_t *, const pthread_attr_t *, void *(*)(void *), void *);
	static void	*(*last_start_routine)(void *);
	static int	same_count, failed;

	if (NULL == real_pthread_create)
		real_pthread_create = (int (*)(pthread_t *, const pthread_attr_t *, void *(*)(void *), void *))
					dlsym(RTLD_NEXT, "pthread_create");
	same_count = (start_routine == last_start_routine) ? (same_count + 1) : 1;
	last_start_routine = start_routine;
	if (!failed && (FAIL_AT == same_count))
	{
		failed = 1;
		fprintf(stderr, "ydb1309_threadfail : sent SIGTERM and failed pthread_create() for worker thread %d\n", FAIL_AT);
		kill(getpid(), SIGTERM);
		return EAGAIN;
	}
	return real_pthread_create(thread, attr, start_routine, arg);
}

static void delay_if_not_main_thread(void)
{
	if (syscall(SYS_gettid) != getpid())
		usleep(READ_DELAY_USEC);
}

ssize_t pread(int fd, void *buf, size_t count, off_t offset)
{
	static ssize_t	(*real_pread)(int, void *, size_t, off_t);

	if (NULL == real_pread)
		real_pread = (ssize_t (*)(int, void *, size_t, off_t))dlsym(RTLD_NEXT, "pread");
	delay_if_not_main_thread();
	return real_pread(fd, buf, count, offset);
}

ssize_t pread64(int fd, void *buf, size_t count, off_t offset)
{
	static ssize_t	(*real_pread64)(int, void *, size_t, off_t);

	if (NULL == real_pread64)
		real_pread64 = (ssize_t (*)(int, void *, size_t, off_t))dlsym(RTLD_NEXT, "pread64");
	delay_if_not_main_thread();
	return real_pread64(fd, buf, count, offset);
}
