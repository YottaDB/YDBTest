/****************************************************************
 *								*
 * Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
/* This file exists to edit it's own command line to help test the cmdline option
 * for the $ZGETJPI function.
 * The file is intended to be called with one argument that is a single character long, that char is replaced with a space.
 * then sleeps for 20 seconds
 */
int main(int argc, char *argv[])
{
	if (argc == 2)
	{
		if (argv[1][0] != '\0' && argv[1][1] == '\0')/* Check to make sure that the input line is exactly 1 character long. */
		{
			memset(argv[1], ' ', sizeof(char));
			sleep(20);
		}
		else
		{
			printf("error, command line argument of size 1 expected but not found\n");
			if(argv[1][0] == '\0')
				printf("found empty argument instead\n");
			else
				printf("argument size was bigger than 1\n");
		}
	} else
	{
		printf("error, expected 1 command line argument but found %d\n", argc - 1);
	}
}
