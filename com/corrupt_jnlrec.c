/****************************************************************
*								*
*	Copyright 2005, 2014 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
#include "ostype.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#ifdef __UNIX__
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/types.h>
#else
#include <file.h>
#include <unixio.h>
#include <stat.h>
#endif

#define WRITE_GRANULARITY 4

#define MIN_CORRUPT 512

#define PrintUsage									\
{											\
	printf("\nUsage:\n");								\
	printf("\t%s <File_name> <LastEpochOffset> <FileSize> \n\n", argv[0]);		\
	exit(1);									\
}

int main (int argc, char *argv[])
{
	int 		fd, seed, i;
	unsigned int	badDataStartOffset, len, lastEpochOffset, OsFileSize;
	char 		jnlfn[256], *buff;

	if (argc != 4)
		PrintUsage;
	strcpy(jnlfn, argv[1]);
	lastEpochOffset = atoi(argv[2]);
	OsFileSize = atoi(argv[3]);
	if (lastEpochOffset >= OsFileSize)
	{	/* epoch is the last record in the journal file. Cant do much with it. See <TEST_E_RUN_corrupt_jnlrec> */
		printf ("corrupt_jnlrec-I-SKIP : lastepoch = %x [%d] : osfilesize = %x [%d]\n",
			lastEpochOffset, lastEpochOffset, OsFileSize, OsFileSize);
		exit(0);
	}
	if ( -1 == (fd = open(jnlfn, O_RDWR, 0)))
	{
		printf("corrupt_jnlrec-E- Cannot open file %s\n", jnlfn);
		exit(1);
	}
	seed = time(NULL) * OsFileSize;
	srand48(seed);

	len = (OsFileSize - lastEpochOffset) * drand48();
	len = (len + WRITE_GRANULARITY -1)/ WRITE_GRANULARITY * WRITE_GRANULARITY;
	badDataStartOffset = (drand48() < 0.5) ? lastEpochOffset : (lastEpochOffset + len);

	if (-1 == lseek(fd, badDataStartOffset, SEEK_SET))
	{
		printf("corrupt_jnlrec-E- lseek command failed file file %s at offset %d\n", jnlfn, badDataStartOffset);
		exit(1);
	}
	len = (OsFileSize - badDataStartOffset) * drand48();

	if (badDataStartOffset + len > OsFileSize)
	{
		printf ("corrupt_jnlrec-I-SKIP_LESS_THAN_512 : lastepoch = %x [%d] : startoffset = %x [%d] : len = %x [%d] "
			": osfilesize = %x [%d]\n", lastEpochOffset, lastEpochOffset,
			badDataStartOffset, badDataStartOffset, len, len, OsFileSize, OsFileSize);
		exit(0);
	}
	buff = (char *) malloc(len * sizeof(char));
	for ( i = 0; i < len ; i++)
		buff[i] = 255 * drand48();	/* Fill with random data */
	if (-1 == write(fd, buff, len))
	{
		printf("corrupt_jnlrec-E- write command failed for file %s to write %d bytes at offset %d\n",
			jnlfn, len, badDataStartOffset);
		exit(1);
	}
	fsync(fd);
	close(fd);
	printf("corrupt_jnlrec-I-Now Journal file %s is corrupt from offset %d. Length %d\n",jnlfn, badDataStartOffset, len);
	return 0;
}
