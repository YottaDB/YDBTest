/****************************************************************
 *								*
 * Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <libyottadb.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/wait.h>

#include <sys/stat.h>	/* needed for "creat" */
#include <fcntl.h>	/* needed for "creat" */
#include <pthread.h>

#define BASEVAR "basevar"
#define VALUE1	"value"

#define ERRBUF_SIZE	1024

void		*childthread(void *threadparm);

int main()
{
	int		status;
	ydb_buffer_t	basevar, value1;
	char		errbuf[ERRBUF_SIZE];
	pthread_t	thread_id;



	/* Subtest not needed for SimpleThreadAPI */

	printf("### Test Functionality of ydb_thread_is_main() in the SimpleAPI ###\n\n"); fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	/* Run ydb_init() to re-initialize SimpleAPI environment */
	status = ydb_init();
	YDB_ASSERT(YDB_OK == status);

	printf("# Test ydb_thread_is_main() returns YDB_OK since current process is singular and inherently main\n"); fflush(stdout);
	status = ydb_thread_is_main();
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Line[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	} else
	{
		printf("ydb_thread_is_main() returns YDB_OK as expected\n");
		fflush(stdout);
	}

	printf("\n# Run ydb_thread_is_main() in separate thread, expect YDB_NOTOK return\n");
	fflush(stdout);

	status = pthread_create(&thread_id, NULL, childthread, NULL);
	YDB_ASSERT(0 == status);

	/* Wait for thread to finish */
	status = pthread_join(thread_id, NULL);
	YDB_ASSERT(0 == status);


	printf("\n# Run ydb_exit(), and subsequently run ydb_thread_is_main(). This should return a YDB_ERR_CALLINAFTERXIT error\n"); fflush(stdout);
	status = ydb_exit();
	YDB_ASSERT(YDB_OK == status);

	status = ydb_thread_is_main();
	if (YDB_ERR_CALLINAFTERXIT == status)
	{
		printf("ydb_thread_is_main() returns YDB_ERR_CALLINAFTERXIT as expected\n");
		fflush(stdout);
	}

	return YDB_OK;
}

void *childthread(void *threadparm)
{
	int	status;
	char	errbuf[ERRBUF_SIZE];

	status = ydb_thread_is_main();
	if (YDB_NOTOK != status)
	{
		printf("ydb_thread_is_main() returned something else, %d\n", status);
		fflush(stdout);
	} else
	{
		printf("ydb_thread_is_main() returns YDB_NOTOK as expected\n");
		fflush(stdout);
	}

}
