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
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>

#if !defined(__sparc) && !defined(boolean_t)
	typedef int boolean_t;
#endif

#ifndef FALSE
#	define FALSE 0
#endif
#ifndef TRUE
#	define TRUE 1
#endif

int main()
{
	int file;
	struct stat fileStat;
	char cmd[256];
	boolean_t passed = TRUE; /* hope for the best */
	/* Diagnostically: This command can be used on systems that fully support the proc file system("ls -li /proc/self/fd"); */
	/* Start looking for file descriptor after stdin, stdout, and stderr */
	for (file = 3; file < 255; file++)
	{
		if (!fstat(file, &fileStat))
		{
			if (S_ISREG(fileStat.st_mode) || S_ISFIFO(fileStat.st_mode) || S_ISSOCK(fileStat.st_mode))
			{
				passed = FALSE;
				fprintf(stderr, "File Descriptor:%d\n", file);
				if (S_ISREG(fileStat.st_mode))
				{
					fprintf(stderr, "File inode:%d\n", (int)fileStat.st_ino);
					sprintf(cmd, "find . -inum %d", (int)fileStat.st_ino);
					system(cmd);
					fprintf(stderr, "\n\n");
				}
				if (S_ISFIFO(fileStat.st_mode)) fprintf(stderr, "FIFO:[%d]\n", (int)fileStat.st_ino);
				if (S_ISSOCK(fileStat.st_mode)) fprintf(stderr, "SOCKET:[%d]\n", (int)fileStat.st_ino);
			}
		}
	}
	if (passed)
		fprintf(stderr, "PASSED\n");
	else
		fprintf(stderr, "FAILED\n");
	return 0;
}
