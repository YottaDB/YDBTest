/****************************************************************
*								*
 * Copyright (c) 2013-2015 Fidelity National Information 	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <utime.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#if defined st_mtime
#  define st_nmtime		st_mtim.tv_nsec
#elif defined(_AIX)
#  define st_nmtime		st_mtime_n
#elif defined(__hpux) && defined(__ia64)
#  define st_nmtime		st_nmtime
#endif

/* This is a helper program for the v61000/zlink_times test to ensure correct
 * timestamp modifications for the specified files.
 */
int main(int argc, const char* argv[])
{
	int		i, option;
	struct stat	buf;
	struct timeval	ftimes[2];

	option = atoi(argv[1]);
	gettimeofday(&ftimes[0], NULL);
	ftimes[1].tv_sec = ftimes[0].tv_sec = ftimes[0].tv_sec - 1;
	ftimes[1].tv_usec = ftimes[0].tv_usec = 0;	/* To prevent HP-UX Itanium boxes from rounding up. */

	if (1 == option)
	{	/* Make the timestamps one second apart. */
		utimes(argv[2], ftimes);
		ftimes[1].tv_sec = ftimes[0].tv_sec = ftimes[0].tv_sec + 1;
		utimes(argv[3], ftimes);
	} else if (2 == option)
	{	/* Make the timestamps one microsecond apart, if possible. */
		ftimes[1].tv_usec = ftimes[0].tv_usec = 1;
		utimes(argv[2], ftimes);
		stat(argv[2], &buf);
		/* In case this box does not support microsecond-level timestamps, add one second */
		if (1000 != buf.st_nmtime)
			ftimes[1].tv_sec = ftimes[0].tv_sec = ftimes[0].tv_sec + 1;
		else
			ftimes[1].tv_usec = ftimes[0].tv_usec = 2;
		utimes(argv[3], ftimes);
	} else if (3 == option)
	{	/* Make the timestamps the same. */
		utimes(argv[2], ftimes);
		utimes(argv[3], ftimes);
	} else
        {	/* Print the time at which the last modification to each specified file was made. */
                for (i = 2; i < argc; i++)
                {
                        stat(argv[i], &buf);
                        fprintf(stderr, "@ %d.%d %s was modified\n", (int)buf.st_mtime, (int)buf.st_nmtime, argv[i]);
                }
        }

	return 0;
}
