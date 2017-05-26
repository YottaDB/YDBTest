/****************************************************************
*								*
*	Copyright 2013, 2015 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>

#define MUMPS_EXE_STR           "/mumps"

int main(int argc, char* argv[])
{
	int	sockets[2], child, status;
	int	sockets2[2];
	char	buf[1024];
	char	*buf2="(From parent.)\n";
	char	tbuff[256];
	char 	cbuff[10];
	char	mbuff[256];
	char	*gtmargv[5];
	char	*c1;
	int	splitp;

	/* no split $p socket */
	splitp = 0;
	/* any argument will be taken as split $p socket */
	if (1 < argc)
		splitp = 1;

	/* Get the socket pair */
	if (0 > socketpair(AF_UNIX, SOCK_STREAM, 0, sockets))
	{
		printf("error %d on socketpair :%s\n", errno,strerror(errno));
		exit(1);
	}

	/* Get second socket pair if split $p */

	if (splitp && (0 > socketpair(AF_UNIX, SOCK_STREAM, 0, sockets2)))
	{
		printf("error %d on socketpair2 :%s\n", errno,strerror(errno));
		exit(1);
	}
	/* create child process */
	if (-1 == (child = fork()))
	{
		printf("fork error %d ", errno);
		exit(1);
	}
	if (0 != child)
	{  /* this is the parent */
		/* close child's end of socket */
		close(sockets[0]);

		if (splitp)
		{
			/* close child's end of socket2 if split $p */
			close(sockets2[0]);

			/* send a message on the socket2 which will be stdin to mumps child process */
			write(sockets2[1], buf2, strlen(buf2));
		}

		memset(buf, 0, sizeof(buf));
		fputs("parent:-->", stdout);
		while (status = read(sockets[1], buf, sizeof(buf)))
		{
			if (0 > status)
			{
				printf("error %d reading socket ", errno);
				exit(1);
			}
			fwrite(buf, 1, status, stdout);
		}
		fputs(" \n", stdout);
		fflush(stdout);
		close(sockets[1]);
		if (splitp)
			close(sockets2[1]);
		wait(NULL);
		exit(0);
	} else
	{ /* the child */
		/* close parent's end of socket */
		close(sockets[1]);
		/* close parent's end of 2nd socket if split $p*/
		if (splitp)
			close(sockets2[1]);
		c1 = getenv("gtm_exe");
		if (!c1)
			printf("gtm_exe is not defined. Define gtm version first.\n");
		sprintf(tbuff, "%s%s", c1, MUMPS_EXE_STR);
		strcpy(cbuff, "-run");
		if (splitp)
			strcpy(mbuff, "^sockpairm2");
		else
			strcpy(mbuff, "^sockpairm");
		gtmargv[0] = tbuff;
		gtmargv[1] = cbuff;
		gtmargv[2] = mbuff;
		gtmargv[3] = 0;
		if (splitp)
			dup2(sockets2[0], 0);
		else
			dup2(sockets[0], 0);
		dup2(sockets[0], 1);
		dup2(sockets[0], 2);
		close(sockets[0]);
		if (splitp)
			close(sockets2[0]);
		execv(tbuff,  (char *const *)gtmargv);
		exit(-1);
	}
}
