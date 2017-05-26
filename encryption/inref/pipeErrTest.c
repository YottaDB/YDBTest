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
#include <sys/stat.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	char	buff;
	int	status;

	while (1)
	{
		status = read(0, (void *)&buff, 1);
		if (-1 == status)
		{	/* error on read */
			if (errno != EINTR)
			{
				printf("errno = %d\n", errno);
				exit(1);
			}
			continue;
		} else if (0 == status)
		{	/* end of file */
			exit(1);
		}
		write(1, (void *)&buff, 1);
		write(2, (void *)&buff, 1);
	}
}
