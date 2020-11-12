/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <string.h>
#include "libyottadb.h"

#define MAX_LOG_SIZE 5000
#define MAX_ERR_SIZE 2048

/* Uses ydb_cip to call mumps routine from
 * C and the mumps routine writes the name
 * in the syslog file by calling $zsyslog()
 * routine.
*/
int main(int argc, char* argv[])
{
	ci_name_descriptor	callin;
	int			status;
	int 			i;
	char 			err[2048];
	char 			log[5000];

	for (i = 1; i < argc; i++)
	{
		strncat(log, argv[i], strlen(argv[i]));
		strncat(log, " ", 1);
	}
	err[0] = '\0';
	ydb_init();
	callin.rtn_name.address = "tst";
	callin.rtn_name.length = 3;
	callin.handle = NULL;
	status = ydb_cip(&callin, log, &err);
	return 0;
}
