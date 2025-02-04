/****************************************************************
 *								*
 * Copyright (c) 2019-2025 YottaDB LLC. and/or its subsidiaries.	*
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

#define	LOCK_TIMEOUT	1000000
#define ERRBUF_SIZE	1024

#define BASEVAR "basevar"
#define VALUE1	"value"

#define	CHECK_STATUS(str, status)													\
{																	\
	if (strcmp(str, "ydb_init()") == 0)												\
	{																\
		if (-YDB_ERR_CALLINAFTERXIT == (uintptr_t)status)									\
			printf(" --> Invoke %-28s after ydb_exit() : Return value is -YDB_ERR_CALLINAFTERXIT as expected\n", str);	\
		else															\
		{															\
			printf(" --> Invoke %s after ydb_exit() : Return value : Expected = -YDB_ERR_CALLINAFTERXIT (%d)"		\
					": Actual = %ld\n", str, -YDB_ERR_CALLINAFTERXIT, (uintptr_t)status);				\
			ydb_zstatus(errbuf, ERRBUF_SIZE);										\
			printf("[Line %d]: %s\n", __LINE__, errbuf);									\
		}															\
	} else if (strcmp(str, "ydb_exit()") == 0)											\
	{																\
		if (YDB_OK == status)													\
			printf(" --> Invoke %-28s after ydb_exit() : Return value is YDB_OK as expected\n", str);			\
		else															\
		{															\
			printf(" --> Invoke %s after ydb_exit() : Return value : Expected = YDB_OK"					\
					": Actual = %ld\n", str, (uintptr_t)status);							\
			ydb_zstatus(errbuf, ERRBUF_SIZE);										\
			printf("[Line %d]: %s\n", __LINE__, errbuf);									\
		}															\
	} else if (strcmp(str, "ydb_malloc()") == 0)											\
	{																\
		if (YDB_ERR_CALLINAFTERXIT == (uintptr_t)status)									\
			printf(" --> Invoke %-28s after ydb_exit() : Return value is YDB_ERR_CALLINAFTERXIT as expected\n", str);	\
		else															\
		{															\
			printf(" --> Invoke %s after ydb_exit() : Return value : Expected = YDB_ERR_CALLINAFTERXIT (%d)"		\
					": Actual = %ld\n", str, YDB_ERR_CALLINAFTERXIT, (uintptr_t)status);				\
		}															\
	} else																\
	{																\
		if (YDB_ERR_CALLINAFTERXIT == (uintptr_t)status)									\
			printf(" --> Invoke %-28s after ydb_exit() : Return value is YDB_ERR_CALLINAFTERXIT as expected\n", str);	\
		else															\
		{															\
			printf(" --> Invoke %s after ydb_exit() : Return value : Expected = YDB_ERR_CALLINAFTERXIT (%d)"		\
					": Actual = %ld\n", str, YDB_ERR_CALLINAFTERXIT, (uintptr_t)status);				\
			ydb_zstatus(errbuf, ERRBUF_SIZE);										\
			printf("[Line %d]: %s\n", __LINE__, errbuf);									\
		}															\
	}																\
	fflush(stdout);															\
}

int main()
{
	int			i, status;
	char			errbuf[ERRBUF_SIZE];
	ydb_buffer_t		basevar, value1, value2, badbasevar;
	unsigned int		data_value;
	int			dst_used;
	char			valuebuff[64];
	ydb_fileid_ptr_t	fileid1, fileid2;
	ydb_string_t		filename;
	size_t			size;
	unsigned long long	time;
	intptr_t		timer_id;
	void			*ptr;

	printf("### Test that any SimpleThreadAPI call after ydb_exit() returns YDB_ERR_CALLINAFTERXIT error ###\n");
	fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	value2.buf_addr = &valuebuff[0];
	value2.len_used = 0;
	value2.len_alloc = sizeof(valuebuff);


	printf("# Invoke ydb_set_st() to initialize SimpleThreadAPI environment\n");
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	YDB_ASSERT(0 == status);

	printf("# Invoke ydb_exit() to shutdown/close SimpleThreadAPI environment\n");
	status = ydb_exit();
	YDB_ASSERT(0 == status);

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
	status = ydb_ci_tab_switch_t(YDB_NOTTP, NULL, (uintptr_t)NULL, NULL); CHECK_STATUS("ydb_ci_tab_switch_t()", status);
	status = ydb_exit(); CHECK_STATUS("ydb_exit()", status);
	status = ydb_file_id_free_t(YDB_NOTTP, NULL, NULL); CHECK_STATUS("ydb_file_id_free_t()", status);
	status = ydb_file_is_identical_t(YDB_NOTTP, NULL, &fileid1, &fileid2); CHECK_STATUS("ydb_file_is_identical_t()", status);
	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &filename, &fileid1); CHECK_STATUS("ydb_file_name_to_id_t()", status);
	if(0 == strcmp(getenv("tst_image"), "pro")){
		printf(" --> Invoke ydb_fork_n_core()            after ydb_exit() : There is no return value since function is void\n"); fflush(stdout);
		ydb_fork_n_core();
	}
	status = ydb_init(); CHECK_STATUS("ydb_init()", status);
	i = 0;
	status = ydb_message_t(YDB_NOTTP, NULL, i, &value1); CHECK_STATUS("ydb_message_t()", status);
	status = ydb_stdout_stderr_adjust_t(YDB_NOTTP, NULL); CHECK_STATUS("ydb_stdout_stderr_adjust_t()", status);
	status = ydb_thread_is_main(); CHECK_STATUS("ydb_thread_is_main()", status);
	printf(" --> Invoke ydb_timer_cancel()           after ydb_exit() : There is no return value since function is void\n"); fflush(stdout);
	timer_id = 0;
	ydb_timer_cancel_t(YDB_NOTTP, NULL, timer_id);
	time = 0;
	status = ydb_timer_start_t(YDB_NOTTP, NULL, timer_id, time, NULL, data_value, &valuebuff); CHECK_STATUS("ydb_timer_start_t()", status);

	return 0;
}
