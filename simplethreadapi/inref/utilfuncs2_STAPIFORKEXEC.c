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
#include <errno.h>
#include <sys/wait.h>


#define	LOCK_TIMEOUT	1000000
#define ERRBUF_SIZE	1024

#define BASEVAR "basevar"
#define VALUE1	"value"


#define	CHECK_STATUS(str, status)															\
{																			\
	if (strcmp(str, "ydb_init()") == 0)														\
	{																		\
		if (-YDB_ERR_STAPIFORKEXEC == (uintptr_t)status)											\
			printf(" --> Invoke %-28s in the child process after fork() : Return value is -YDB_ERR_STAPIFORKEXEC as expected\n", str);	\
		else																	\
		{																	\
			printf(" --> Invoke %s in the child process after fork() : Return value : Expected = -YDB_ERR_STAPIFORKEXEC (%d)"		\
					": Actual = %ld\n", str, -YDB_ERR_STAPIFORKEXEC, (uintptr_t)status);						\
			ydb_zstatus(errbuf, ERRBUF_SIZE);												\
			printf("[Line %d]: %s\n", __LINE__, errbuf);											\
		}																	\
	} else if (strcmp(str, "ydb_exit()") == 0)													\
	{																		\
		if (0 == (uintptr_t)status)														\
			printf(" --> Invoke %-28s in the child process after fork() : Return value is YDB_OK as expected\n", str);			\
		else																	\
		{																	\
			printf(" --> Invoke %s in the child process after fork() : Return value : Expected = YDB_OK"					\
					": Actual = %ld\n", str, (uintptr_t)status);									\
			ydb_zstatus(errbuf, ERRBUF_SIZE);												\
			printf("[Line %d]: %s\n", __LINE__, errbuf);											\
		}																	\
	} else																		\
	{																		\
		if (YDB_ERR_STAPIFORKEXEC == (uintptr_t)status)												\
			printf(" --> Invoke %-28s in the child process after fork() : Return value is YDB_ERR_STAPIFORKEXEC as expected\n", str);	\
		else																	\
		{																	\
			printf(" --> Invoke %s in the child process after fork() : Return value : Expected = YDB_ERR_STAPIFORKEXEC (%d)"		\
					": Actual = %ld\n", str, YDB_ERR_STAPIFORKEXEC, (uintptr_t)status);						\
			ydb_zstatus(errbuf, ERRBUF_SIZE);												\
			printf("[Line %d]: %s\n", __LINE__, errbuf);											\
		}																	\
	}																		\
	fflush(stdout);																	\
}




int main()
{
	int			i, status, stat, ret, save_errno;
	char			errbuf[ERRBUF_SIZE];
	ydb_buffer_t		basevar, value1, value2, badbasevar;
	pid_t			child;
	unsigned int		data_value;
	int			dst_used;
	char			valuebuff[64];
	ydb_fileid_ptr_t	fileid1, fileid2;
	ydb_string_t		filename;
	size_t			size;
	unsigned long long	time;
	intptr_t		timer_id;
	void			*ptr;

	printf("### Test that any SimpleAPI call in child process after fork() returns YDB_ERR_STAPIFORKEXEC error if exec() isn't used ###\n");
	fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	value2.buf_addr = &valuebuff[0];
	value2.len_used = 0;
	value2.len_alloc = sizeof(valuebuff);


	printf("# Invoke ydb_set_st() to initialize SimpleAPI environment\n"); fflush(stdout);
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	YDB_ASSERT(0 == status);

	printf("# Fork the process and test SimpleThreadAPI calls\n"); fflush(stdout);
	child = fork();
	if (0 == child)
	{	/* child process */
		printf("# Inside Child process\n"); fflush(stdout);

		status = ydb_data_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &data_value); CHECK_STATUS("ydb_data_st()", status);
		status = ydb_delete_excl_st(YDB_NOTTP, NULL, 0, NULL); CHECK_STATUS("ydb_delete_excl_st()", status);
		status = ydb_delete_st(YDB_NOTTP, NULL, &basevar, 0, NULL, YDB_DEL_NODE); CHECK_STATUS("ydb_delete_st()", status);
		status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value2); CHECK_STATUS("ydb_get_st()", status);
		status = ydb_incr_st(YDB_NOTTP, NULL, &basevar, 0, NULL, NULL, &value2); CHECK_STATUS("ydb_incr_st()", status);
		status = ydb_lock_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, 0); CHECK_STATUS("ydb_lock_st()", status);
		status = ydb_lock_decr_st(YDB_NOTTP, NULL, &basevar, 0, NULL); CHECK_STATUS("ydb_lock_decr_st()", status);
		status = ydb_lock_incr_st(YDB_NOTTP, NULL, LOCK_TIMEOUT, &basevar, 0, NULL); CHECK_STATUS("ydb_lock_incr_st()", status);
		status = ydb_node_next_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS("ydb_node_next_st()", status);
		status = ydb_node_previous_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS("ydb_node_previous_st()", status);
		status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1); CHECK_STATUS("ydb_set_st()", status);
		status = ydb_str2zwr_st(YDB_NOTTP, NULL, &value1, &value2); CHECK_STATUS("ydb_str2zwr_st()", status);
		status = ydb_subscript_next_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1); CHECK_STATUS("ydb_subscript_next_st()", status);
		status = ydb_subscript_previous_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1); CHECK_STATUS("ydb_subscript_previous_st()", status);
		status = ydb_tp_st(YDB_NOTTP, NULL, NULL, NULL, NULL, 0, NULL); CHECK_STATUS("ydb_tp_st()", status);
		status = ydb_zwr2str_st(YDB_NOTTP, NULL, &value1, &value2); CHECK_STATUS("ydb_zwr2str_st()", status);

		status = ydb_child_init(NULL); CHECK_STATUS("ydb_child_init()", status);
		status = ydb_ci_t(YDB_NOTTP, NULL, ""); CHECK_STATUS("ydb_ci_t()", status);
		status = ydb_cip_t(YDB_NOTTP, NULL, NULL); CHECK_STATUS("ydb_cip_t()", status);
		status = ydb_ci_tab_open_t(YDB_NOTTP, NULL, "", NULL); CHECK_STATUS("ydb_ci_tab_open_t()", status);
		status = ydb_ci_tab_switch_t(YDB_NOTTP, NULL, (uint64_t)NULL, NULL); CHECK_STATUS("ydb_ci_tab_switch_t()", status);
		status = ydb_exit(); CHECK_STATUS("ydb_exit()", status);
		status = ydb_file_id_free_t(YDB_NOTTP, NULL, NULL); CHECK_STATUS("ydb_file_id_free_t()", status);
		status = ydb_file_is_identical_t(YDB_NOTTP, NULL, &fileid1, &fileid2); CHECK_STATUS("ydb_file_is_identical_t()", status);
		status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &filename, &fileid1); CHECK_STATUS("ydb_file_name_to_id_t()", status);
/*		To be fixed later: function returns error code that cannot be redirected
		printf(" --> Invoke ydb_fork_n_core()            in the child process after fork() : There is no return value since function is void\n"); fflush(stdout);
		ydb_fork_n_core();
*/
		status = ydb_init(); CHECK_STATUS("ydb_init()", status);
		status = ydb_message_t(YDB_NOTTP, NULL, i, &value1); CHECK_STATUS("ydb_message_t()", status);
		status = ydb_stdout_stderr_adjust_t(YDB_NOTTP, NULL); CHECK_STATUS("ydb_stdout_stderr_adjust_t()", status);
		/* ydb_thread_is_main() does not return YDB_ERR_STAPIFORKEXEC, checking to make sure return is YDB_NOTOK */
  		printf(" --> Invoke ydb_timer_cancel()           in the child process after fork() : There is no return value since function is void\n"); fflush(stdout);
		ydb_timer_cancel_t(YDB_NOTTP, NULL, timer_id);
		status = ydb_timer_start_t(YDB_NOTTP, NULL, timer_id, time, NULL, data_value, &valuebuff); CHECK_STATUS("ydb_timer_start_t()", status);

	} else
	{	/* parent process */
		/* Wait for child to terminate */
		do
		{
			ret = waitpid(child, &stat, 0);
			save_errno = errno;
		} while ((-1 == ret) && (EINTR == save_errno));
		YDB_ASSERT(-1 != ret);
		printf("# Child Process has finished\n"); fflush(stdout);
	}
	return YDB_OK;

}
