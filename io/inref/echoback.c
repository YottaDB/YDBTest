#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

/* Simple routine to echo lines from standard input alternately to stdout and stderr */

int
main(int argc, char *argv[])
{
  char buf;
  char nl='\012';
  int i;
  char input[200];
  
  while (1)
    {
      int j;
      if (NULL == fgets(input,200,stdin))
	      break;

      fprintf(stdout,"stdout - %s",input);
      fflush(stdout);

      if (NULL == fgets(input,200,stdin))
	      break;
      fprintf(stderr,"stderr - %s",input);
      fflush(stderr);
    }
}
