#include <sys/stat.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#define FALSE 0
#define TRUE 1

#define EBCDIC_NEWLINE  '\025'
#define EBCDIC_SPACE '\100'
#define NEWLINE  '\n'
#define SPACE '\040'

#ifdef __MVS__
#define ZOS_ONLY(x)	x
#else
#define ZOS_ONLY(x)
#endif

/* Reads a non-blocked character at a time and echos it to stdout.
   If the character is a newline then don't echo it.  If there is
   and argument passed then don't echo a space.  This is used to
   test failure of an application to return valid input.  In a non-fixed
   test it is the lack of a newline, and in the fixed test it is the lack
   of the correct number of characters back after io has begun.  */

int
main(int argc, char *argv[])
{
	char nl='\012';
	unsigned char schar;
	int geton = FALSE;
	int save;
  
	save = fcntl(0, F_GETFL);
	fcntl(0, F_SETFL, save|O_NONBLOCK);

	while (1)
	{
		int j;
		int k;

		if (geton == FALSE)
		{
			j = read(0,(void *)&schar,1);
			if (-1 == j)
			{
				if (EAGAIN != errno)
					printf("errno = %d\n",errno);
				continue;
			}
			if (0 == j)
			{
				/* end of file */
				exit(1);
			}
			if (NEWLINE == (char)schar ZOS_ONLY(|| EBCDIC_NEWLINE == (char)schar))
				continue;
			if ((2 == argc) && (SPACE == (char)schar ZOS_ONLY(|| EBCDIC_SPACE == (char)schar)))
				continue;
			fprintf(stdout,"%c",(char )schar);
			fflush(stdout);
		}
	}
}

