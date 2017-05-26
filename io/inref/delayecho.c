/****************************************************************
 *								*
 *	Copyright 2011, 2014 Fidelity Information Services, Inc	*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
#include <sys/stat.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#define FALSE 0
#define TRUE 1
int
main(int argc, char *argv[])
{
	char nl='\012';
	unsigned char schar;
	int counter=0;
	int chars_per_delay;
	int seconds;
	int save;

	if (3 != argc)
	{
		printf("usage: delayecho <chars_per_delay> <seconds>\n");
		exit(1);
	}
	chars_per_delay = atoi(argv[1]);
	seconds = atoi(argv[2]);

	save = fcntl(0, F_GETFL);
	fcntl(0, F_SETFL, save|O_NONBLOCK);

	while (1)
	{
		int j;
		int k;

		j = read(0, (void *)&schar, 1);
		if (j == -1)
		{
			if (errno != EAGAIN)
			{
				printf("errno = %d\n",errno);
				exit(1);
			}
			continue;
		}
		if (j == 0)
		{	/* end of file */
			exit(1);
		}
		if (counter++ == chars_per_delay)
		{
			sleep(seconds);
			counter = 0;
		}
		write(1, (void *)&schar, 1);
	}
}

