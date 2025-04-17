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

#ifndef YDB474_INCLUDED
#define YDB474_INCLUDED

#include "libyottadb.h"

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

char *read_json_file(const char *json_file)
{
	FILE	*fd;
	long	size;
	char	*json_buffer;

	fd = fopen(json_file, "r");
	if (NULL == fd)
	{
		fprintf(stderr, "fopen(): %s\n", strerror(errno));
		return NULL;
	}
	if (-1 == fseek(fd, 0, SEEK_END))
	{
		fprintf(stderr, "fseek(): %s\n", strerror(errno));
		fclose(fd);
		return NULL;
	}
	size = ftell(fd);
	if (-1 == size)
	{
		fprintf(stderr, "ftell(): %s\n", strerror(errno));
		fclose(fd);
		return NULL;
	}
	if (-1 == fseek(fd, 0, SEEK_SET))
	{
		fprintf(stderr, "fseek(): %s\n", strerror(errno));
		fclose(fd);
		return NULL;
	}
	json_buffer = malloc(size);
	if (NULL == json_buffer)
	{
		fprintf(stderr, "malloc(): %s\n", strerror(errno));
		fclose(fd);
		return NULL;
	}
	if ((size > fread(json_buffer, size, 1, fd)) && ferror(fd))
	{
		fprintf(stderr, "fread(): Error reading %s\n", json_file);
		return NULL;
	}
	json_buffer[size - 1] = '\0';
	if (0 != fclose(fd))
	{
		fprintf(stderr, "fclose(): %s\n", strerror(errno));
		return NULL;
	}
	return json_buffer;
}

#endif /* YDB474_INCLUDED */
