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

/* Usage : ydb1292_stopthreads <outfile> <program> [<arg>...]
 *
 * Runs <program> (a MUPIP JOURNAL command) as a child process with stdout and stderr going to <outfile>.
 * As soon as the child has more than one thread, stops it with SIGSTOP and, if it still has more than one thread,
 * lowers its address space limit (RLIMIT_AS) to the address space it is using, sends it SIGTERM (what MUPIP STOP sends)
 * and lets it continue with SIGCONT. A worker thread then sees the forced exit and calls "pthread_exit" at a point
 * where no new memory can be mapped. Waits for the child and reports how it ended.
 */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE	/* for prlimit() */
#endif
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define	MAX_WAIT_SEC	300

/* Returns the number of threads of process "pid", or -1 if it no longer exists */
static int num_threads(pid_t pid)
{
	char		path[64];
	DIR		*dir;
	struct dirent	*ent;
	int		count;

	snprintf(path, sizeof(path), "/proc/%d/task", (int)pid);
	if (NULL == (dir = opendir(path)))
		return -1;
	count = 0;
	while (NULL != (ent = readdir(dir)))
		if ('.' != ent->d_name[0])
			count++;
	closedir(dir);
	return count;
}

/* Returns the state letter from /proc/<pid>/stat, or 0 if it cannot be read */
static char proc_state(pid_t pid)
{
	char	path[64], buf[512], *ptr;
	FILE	*fp;

	snprintf(path, sizeof(path), "/proc/%d/stat", (int)pid);
	if (NULL == (fp = fopen(path, "r")))
		return 0;
	ptr = fgets(buf, sizeof(buf), fp);
	fclose(fp);
	if ((NULL == ptr) || (NULL == (ptr = strrchr(buf, ')'))))
		return 0;
	return ptr[2];
}

/* Returns VmSize of process "pid" in bytes, or 0 if it cannot be read */
static rlim_t vmsize(pid_t pid)
{
	char		path[64], buf[256];
	FILE		*fp;
	unsigned long	kb;

	snprintf(path, sizeof(path), "/proc/%d/status", (int)pid);
	if (NULL == (fp = fopen(path, "r")))
		return 0;
	kb = 0;
	while (NULL != fgets(buf, sizeof(buf), fp))
		if (1 == sscanf(buf, "VmSize: %lu kB", &kb))
			break;
	fclose(fp);
	return (rlim_t)kb * 1024;
}

/* Returns 1 if libgcc_s is mapped into process "pid", 0 if not. The mapped file can be libgcc_s.so.1 or, where that is a
 * symbolic link (e.g. RHEL), a versioned name like libgcc_s-11-20240719.so.1, so match only the prefix.
 */
static int libgcc_s_mapped(pid_t pid)
{
	char	path[64], buf[1024];
	FILE	*fp;
	int	found;

	snprintf(path, sizeof(path), "/proc/%d/maps", (int)pid);
	if (NULL == (fp = fopen(path, "r")))
		return 0;
	found = 0;
	while (!found && (NULL != fgets(buf, sizeof(buf), fp)))
		if (NULL != strstr(buf, "/libgcc_s"))
			found = 1;
	fclose(fp);
	return found;
}

static void sleep_msec(int msec)
{
	struct timespec	ts;

	ts.tv_sec = msec / 1000;
	ts.tv_nsec = (msec % 1000) * 1000000L;
	nanosleep(&ts, NULL);
}

int main(int argc, char **argv)
{
	pid_t		pid;
	int		fd, status, nthreads, i, stopped;
	struct rlimit	rl;

	if (3 > argc)
	{
		fprintf(stderr, "Usage : %s <outfile> <program> [<arg>...]\n", argv[0]);
		return 1;
	}
	if (0 > (fd = open(argv[1], O_WRONLY | O_CREAT | O_TRUNC, 0644)))
	{
		perror("open");
		return 1;
	}
	pid = fork();
	if (0 > pid)
	{
		perror("fork");
		return 1;
	}
	if (0 == pid)
	{
		dup2(fd, 1);
		dup2(fd, 2);
		close(fd);
		execv(argv[2], &argv[2]);
		perror("execv");
		_exit(127);
	}
	close(fd);
	stopped = 0;
	for (i = 0; i < MAX_WAIT_SEC * 1000; i++)
	{
		nthreads = num_threads(pid);
		if (0 > nthreads)
			break;
		if (1 < nthreads)
		{
			kill(pid, SIGSTOP);
			while ('T' != proc_state(pid))
				sleep_msec(1);
			if (1 < num_threads(pid))
			{
				stopped = 1;
				break;
			}
			/* The threads finished between the two checks. Let the process continue and look again. */
			kill(pid, SIGCONT);
		}
		sleep_msec(1);
	}
	if (stopped)
	{
		printf("Stopped the MUPIP process while it had worker threads\n");
		printf("libgcc_s is %s into it\n", libgcc_s_mapped(pid) ? "mapped" : "NOT mapped");
		if (0 != prlimit(pid, RLIMIT_AS, NULL, &rl))
			printf("prlimit() failed to read the limit : %s\n", strerror(errno));
		else if (0 == (rl.rlim_cur = vmsize(pid)))
			printf("Could not read VmSize of the MUPIP process\n");
		else if (0 != prlimit(pid, RLIMIT_AS, &rl, NULL))
			printf("prlimit() failed : %s\n", strerror(errno));
		else
			printf("Set its address space limit to the address space it is using\n");
		kill(pid, SIGTERM);
		kill(pid, SIGCONT);
		printf("Sent it SIGTERM and SIGCONT\n");
	} else
		printf("The MUPIP process ended before it was seen with worker threads\n");
	if (pid != waitpid(pid, &status, 0))
	{
		perror("waitpid");
		return 1;
	}
	if (WIFSIGNALED(status))
		printf("MUPIP was killed by signal %d\n", WTERMSIG(status));
	else
		printf("MUPIP exited with status %d\n", WEXITSTATUS(status));
	return 0;
}
