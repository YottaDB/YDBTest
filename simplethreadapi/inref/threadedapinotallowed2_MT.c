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

#include "libyottadb.h"

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/stat.h>	/* needed for "creat" */
#include <fcntl.h>	/* needed for "creat" */
#include <pthread.h>
#include <sys/syscall.h> /* needed for "syscall" */

#define	LOCK_TIMEOUT	1000000
#define ERRBUF_SIZE	1024

#define BASEVAR 	"basevar"
#define VALUE1		"value"
#define MAXTHREADS	8
#define	CHECK_STATUS(str, status, fp)																\
{																				\
	if (strcmp(str, "ydb_init()") == 0)															\
	{																			\
		if (YDB_OK == status)																\
			fprintf(fp, " --> Invoke %-28s after SimpleAPI call : Return value is YDB_OK as expected\n", str);					\
		else																		\
		{																		\
			fprintf(fp, " --> Invoke %s after SimpleAPI call : Return value : Expected = YDB_OK"							\
					": Actual = %d\n", str, status);											\
			ydb_zstatus(errbuf, ERRBUF_SIZE);													\
			fprintf(fp, "[Line %d]: %s\n", __LINE__, errbuf);											\
		}																		\
	} else																			\
	{																			\
		if (YDB_ERR_THREADEDAPINOTALLOWED == status)													\
			fprintf(fp, " --> Invoke %-28s after SimpleAPI call : Return value is YDB_ERR_THREADEDAPINOTALLOWED as expected\n", str);		\
		else																		\
		{																		\
			fprintf(fp, " --> Invoke %s after SimpleAPI call : Return value : Expected = YDB_ERR_THREADEDAPINOTALLOWED (%d)"			\
					": Actual = %d\n", str, YDB_ERR_THREADEDAPINOTALLOWED, status);								\
			ydb_zstatus(errbuf, ERRBUF_SIZE);													\
			fprintf(fp, "[Line %d]: %s\n", __LINE__, errbuf);											\
		}																		\
	}																			\
	fflush(stdout);																		\
}

void		*childthread(void *threadparm);

int main()
{
	int			s, status;
	pthread_t		thread_id[MAXTHREADS];
	char			errbuf[ERRBUF_SIZE];
	ydb_buffer_t		basevar, value1, value2, badbasevar;
	unsigned int	 	data_value;
	int			dst_used;
	char			valuebuff[64];

	printf("### Test that any SimpleThreadAPI call after a SimpleAPI call returns YDB_ERR_THREADEDAPINOTALLOWED error ###\n");
	fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	value2.buf_addr = &valuebuff[0];
	value2.len_used = 0;
	value2.len_alloc = sizeof(valuebuff);

	printf("# Invoke ydb_set_s() to initialize SimpleAPI environment\n");
	status = ydb_set_s(&basevar, 0, NULL, &value1);
	YDB_ASSERT(0 == status);

	printf("# Spawn multiple threads to test SimpleThreadAPI functions return a YDB_ERR_THREADEDAPINOTALLOWED error\n");
	fflush(stdout);

	for (s = 0; s < MAXTHREADS; s++)
	{
		status = pthread_create(&thread_id[s], NULL, childthread, NULL);
		YDB_ASSERT(0 == status);
	}

	/* Wait for threads to finish */
	for (s = 0; s < MAXTHREADS; s++)
	{
		status = pthread_join(thread_id[s], NULL);
		YDB_ASSERT(0 == status);
	}

	return YDB_OK;
}


void *childthread(void *threadparm)
{
	int 			status;
	char			errbuf[ERRBUF_SIZE];
	ydb_buffer_t		basevar, value1, value2, badbasevar;
	unsigned int	 	data_value;
	int			dst_used;
	char			valuebuff[64], fileprint[128];
	ydb_fileid_ptr_t	fileid1, fileid2;
	ydb_string_t		filename;
	size_t			size;
	unsigned long long	time1;
	intptr_t		timer_id1;
	void			*ptr;
	pid_t			tid;
	ci_name_descriptor	callin;

	time1 = 1;
	timer_id1 = 1;

	tid = syscall(SYS_gettid);
	sprintf(fileprint, "THREADEDAPINOTALLOWED_%d.txt", tid);
	FILE *fp = fopen(fileprint, "ab+");

	status = ydb_data_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &data_value); CHECK_STATUS("ydb_data_st()", status, fp);
	status = ydb_delete_excl_st(YDB_NOTTP, NULL, 0, NULL); CHECK_STATUS("ydb_delete_excl_st()", status, fp);
	status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, 0, NULL, YDB_DEL_NODE); CHECK_STATUS("ydb_delete_st()", status, fp);
	status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value2); CHECK_STATUS("ydb_get_st()", status, fp);
	status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL, &value2); CHECK_STATUS("ydb_incr_st()", status, fp);
	status = ydb_lock_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, 0); CHECK_STATUS("ydb_lock_st()", status, fp);
	status = ydb_lock_decr_st(YDB_NOTTP, NULL, &basevar, 0, NULL); CHECK_STATUS("ydb_lock_decr_st()", status, fp);
	status = ydb_lock_incr_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, &basevar, 0, NULL); CHECK_STATUS("ydb_lock_incr_st()", status, fp);
	status = ydb_node_next_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS("ydb_node_next_st()", status, fp);
	status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS("ydb_node_previous_st()", status, fp);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1); CHECK_STATUS("ydb_set_st()", status, fp);
	status = ydb_str2zwr_st(YDB_NOTTP, NULL, &value1, &value2); CHECK_STATUS("ydb_str2zwr_st()", status, fp);
	status = ydb_subscript_next_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1); CHECK_STATUS("ydb_subscript_next_st()", status, fp);
	status = ydb_subscript_previous_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1); CHECK_STATUS("ydb_subscript_previous_st()", status, fp);
	status = ydb_tp_st(YDB_NOTTP, NULL, NULL, NULL, NULL, 0, NULL); CHECK_STATUS("ydb_tp_st()", status, fp);
	status = ydb_zwr2str_st(YDB_NOTTP, NULL, &value1, &value2); CHECK_STATUS("ydb_zwr2str_st()", status, fp);
	status = ydb_ci_t(YDB_NOTTP, NULL, "CALL-IN"); CHECK_STATUS("ydb_ci_t()", status, fp);
	status = ydb_cip_t(YDB_NOTTP, NULL, &callin); CHECK_STATUS("ydb_cip_t()", status, fp);
	status = ydb_ci_tab_open_t(YDB_NOTTP, NULL, "", NULL); CHECK_STATUS("ydb_ci_tab_open_t()", status, fp);
	status = ydb_ci_tab_switch_t(YDB_NOTTP, NULL, (uint64_t)NULL, NULL); CHECK_STATUS("ydb_ci_tab_switch_t()", status, fp);
	status = ydb_file_id_free_t(YDB_NOTTP, NULL, NULL); CHECK_STATUS("ydb_file_id_free_t()", status, fp);
	status = ydb_file_is_identical_t(YDB_NOTTP, NULL, &fileid1, &fileid2); CHECK_STATUS("ydb_file_is_identical_t()", status, fp);
	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &filename, &fileid1); CHECK_STATUS("ydb_file_name_to_id_t()", status, fp);
/*	To be fixed later: function returns error code that cannot be redirected
	fprintf(fp, " --> Invoke ydb_fork_n_core()            after SimpleAPI call : There is no return value since function is void\n"); fflush(stdout);
	ydb_fork_n_core();
*/
	status = ydb_init(); CHECK_STATUS("ydb_init()", status, fp);
	status = ydb_message_t(YDB_NOTTP, NULL, 0, &value1); CHECK_STATUS("ydb_message_t()", status, fp);
	status = ydb_stdout_stderr_adjust_t(YDB_NOTTP, NULL); CHECK_STATUS("ydb_stdout_stderr_adjust_t()", status, fp);
	fprintf(fp, " --> Invoke ydb_timer_cancel()           after SimpleAPI call : There is no return value since function is void\n"); fflush(stdout);
	ydb_timer_cancel_t(YDB_NOTTP, NULL, timer_id1);
	status = ydb_timer_start_t(YDB_NOTTP, NULL, timer_id1, time1, NULL, data_value, &valuebuff); CHECK_STATUS("ydb_timer_start_t()", status, fp);
}
