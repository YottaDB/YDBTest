/****************************************************************
*								*
*	Copyright 2008, 2013 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <assert.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

/* Routine echos back stdin to stdout until end of file seen.  It will then continue to exist
   for either 300 sec or if there is a first argument it will be the time in seconds.  The exit
   code will either be 0 or if there is a second argument it will be used as the exit code.
   This is used by independent.m in the io/pipetest to test the deviceparamter "independent" which
   expects the application to keep running after the pipe is closed. It is also used by closestatus.m
   in the io/closestatus to test a pipe's close status in various timeout conditions. */

int
main(int argc, char *argv[])
{
  int itime = 300;
  int exit_code = 0;
  int i;
  char tbuf[1025];
  int save_errno;
  int j;

  /* set itime if argument 1 exists and exit_code if argument 2 exists */
  if (1 < argc)
	  itime = atoi(argv[1]);
  if (2 < argc)
	  exit_code = atoi(argv[2]);
  /* output if input arguments if both exist */
  if (2 < argc)
	  fprintf(stdout,"%d %d\n",itime,exit_code);

  while (1)
    {
      int j;

      /* read 1024 or less */
      j = read(0,tbuf,1024);
      if (-1 == j)
	{
		save_errno = errno;
		if (EAGAIN != save_errno)
			fprintf(stderr,"errno = %d ",save_errno);
		continue;
	}

      if (0 == j)		/* end of file */
	      break;

      tbuf[j]='\0';
      fprintf(stdout,"%s",tbuf);
      fflush(stdout);
    }
  for (i=0; i < itime; i++)
  {
	  /* leave it around for itime seconds */
	  /* this is 300 seconds when testing the "independent" deviceparameter or passed as argument 1 when testing
	     the PIPE CLOSE's attempt to call waitpid() */
	  sleep(1);
  }
  exit(exit_code);
}
