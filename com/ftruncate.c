
#include <stdio.h>

#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

int main(int argc, char *argv[])
{
	char		*src;
	off_t		len;
	struct stat	srcStat;

	if (argc != 3)
	{
		printf ("%s [file] [length] \n", argv[0]);
		exit(1);
	}
	src = argv[1];
	len = atoi(argv[2]);
	if (0 != stat(src, &srcStat))
	{
		printf ("%s : Error with stat\n", src);
		perror("");
		exit(-1);
	}
	if (-1 == truncate(src, len))
	{
		printf ("%s : Error with ftruncate\n", src);
		perror("");
		exit(-1);
	}
}
