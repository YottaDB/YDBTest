/****************************************************************
*								*
*	Copyright 2013, 2014 Fidelity Information Services, Inc	*
*								*
* Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	*
* All rights reserved.						*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include <sys/types.h>
#include <sys/wait.h>
#include <assert.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define USAGE	fprintf(stderr, "usage: %s command [arg0 .. argn]\n", argv[0])

int main(int argc, char* argv[])
{
	int				status;
	int				arg;
	int				optnum, fd;
	int				pid;
	char				*cmd;
	char				**args;
	char				optbuf[2];	/* one digit and a null */

	if (argc < 3)
	{
		USAGE;
		exit(1);
	}

	cmd = argv[1];

	args = (char **) malloc(sizeof(char *) * argc);
	assert(NULL != args);

	for (arg = 0; arg < argc-1; arg++)
	{
		args[arg] = argv[arg+1] ? strdup(argv[arg+1]) : NULL;
	}
	args[arg] = NULL;

	/* Test closing each combination of stdin, stdout, and stderr */
	for (optnum = 0; optnum < 8; optnum++)
	{
		pid = fork();
		assert(-1 != pid);

		if (0 == pid)
		{	/* child */
			for (fd = 0; fd <= 2; fd++)
			{
				if (optnum & (1 << fd))
				{
					status = close(fd);
					assert(0 == status);
				}
			}
			sprintf(optbuf, "%d", optnum);
			setenv("OPTNUM", optbuf, 1);
			execvp(cmd, args);
			assert(0);
		}
		else
		{	/* parent */
			status = wait(NULL);
			assert(pid == status);
		}
	}
	return 0;
}
