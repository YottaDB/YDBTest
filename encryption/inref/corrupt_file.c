/****************************************************************
 *								*
 * Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 * Portions Copyright (c) Fidelity National			*
 * Information Services, Inc. and/or its subsidiaries.		*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <sys/types.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	int offset;
	FILE *fp;
	char buff;
	if (argc != 3)
	{
		printf("usage:<filename> <Offset value>");
		return 1;
	}
	else
	{
		if((fp=fopen(argv[1],"rb+"))==NULL)
		{
			printf("file not found");
			return 1;
		}
		else
		{
			offset = atoi(argv[2]);
			fseek(fp,offset,0);
			buff=fgetc(fp);
			buff=buff+1;
			fseek(fp,offset,0);
			fputc(buff,fp);
		}	fclose(fp);
	}
	 return 0;
}
