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

#define	LOCK_TIMEOUT	1000000
#define ERRBUF_SIZE	1024

#define BASEVAR "basevar"
#define VALUE1	"value"

#define	CHECK_STATUS(str, status)															\
{																			\
	if (strcmp(str, "ydb_init()") == 0)														\
	{																		\
		if (YDB_OK == (uintptr_t)status)													\
			printf(" --> Invoke %-28s after SimpleThreadAPI call : Return value is YDB_OK as expected\n", str);				\
		else																	\
		{																	\
			printf(" --> Invoke %s after SimpleThreadAPI call : Return value : Expected = YDB_OK"						\
					": Actual = %ld\n", str, (uintptr_t)status);									\
			ydb_zstatus(errbuf, ERRBUF_SIZE);												\
			printf("[Line %d]: %s\n", __LINE__, errbuf);											\
		}																	\
	} else if (strcmp(str, "ydb_exit()") == 0)													\
	{																		\
		if (YDB_OK == (uintptr_t)status)													\
			printf(" --> Invoke %-28s after SimpleThreadAPI call : Return value is YDB_OK as expected\n", str);				\
		else																	\
		{																	\
			printf(" --> Invoke %s after SimpleThreadAPI call : Return value : Expected = YDB_OK (%d)"					\
					": Actual = %ld\n", str, YDB_ERR_SIMPLEAPINOTALLOWED, (uintptr_t)status);					\
			ydb_zstatus(errbuf, ERRBUF_SIZE);												\
			printf("[Line %d]: %s\n", __LINE__, errbuf);											\
		}																	\
	} else if (strcmp(str, "ydb_child_init()") == 0)												\
	{																		\
		if (YDB_OK == (uintptr_t)status)													\
			printf(" --> Invoke %-28s after SimpleThreadAPI call : Return value is YDB_OK as expected\n", str);				\
		else																	\
		{																	\
			printf(" --> Invoke %s after SimpleThreadAPI call : Return value : Expected = YDB_OK (%d)"					\
					": Actual = %ld\n", str, YDB_ERR_SIMPLEAPINOTALLOWED, (uintptr_t)status);					\
			ydb_zstatus(errbuf, ERRBUF_SIZE);												\
			printf("[Line %d]: %s\n", __LINE__, errbuf);											\
		}																	\
	} else if (strcmp(str, "ydb_malloc()") == 0)													\
	{																		\
		if (YDB_OK == (uintptr_t)status)													\
			printf(" --> Invoke %-28s after SimpleThreadAPI call : Return value is YDB_ERR_SIMPLEAPINOTALLOWED as expected\n", str);	\
		else																	\
		{																	\
			printf(" --> Invoke %s after SimpleThreadAPI call : Return value : Expected = NULL (%d)"					\
					": Actual = %ld\n", str, YDB_ERR_SIMPLEAPINOTALLOWED, (uintptr_t)status);					\
		}																	\
	} else																		\
	{																		\
		if (YDB_ERR_SIMPLEAPINOTALLOWED == (uintptr_t)status)											\
			printf(" --> Invoke %-28s after SimpleThreadAPI call : Return value is YDB_ERR_SIMPLEAPINOTALLOWED as expected\n", str);	\
		else																	\
		{																	\
			printf(" --> Invoke %s after SimpleThreadAPI call : Return value : Expected = YDB_ERR_SIMPLEAPINOTALLOWED (%d)"			\
					": Actual = %ld\n", str, YDB_ERR_SIMPLEAPINOTALLOWED, (uintptr_t)status);					\
			ydb_zstatus(errbuf, ERRBUF_SIZE);												\
			printf("[Line %d]: %s\n", __LINE__, errbuf);											\
		}																	\
	}																		\
	fflush(stdout);																	\
}

int main()
{
	int		i, status;
	char		errbuf[ERRBUF_SIZE];
	ydb_buffer_t	basevar, value1, value2, badbasevar;
	unsigned int	data_value;
	int		dst_used;
	char		valuebuff[64];
	ydb_fileid_ptr_t	fileid1, fileid2;
	ydb_string_t		filename;
	size_t			size;
	unsigned long long	time;
	intptr_t		timer_id;
	void			*ptr;

	printf("### Test that any SimpleAPI call after using a SimpleThreadAPI call returns YDB_ERR_SIMPLEAPINOTALLOWED error ###\n");
	fflush(stdout);

	YDB_LITERAL_TO_BUFFER(BASEVAR, &basevar);
	YDB_LITERAL_TO_BUFFER(VALUE1, &value1);

	value2.buf_addr = &valuebuff[0];
	value2.len_used = 0;
	value2.len_alloc = sizeof(valuebuff);


	printf("# Invoke ydb_set_st() to initialize SimpleThreadAPI environment\n");
	status = ydb_set_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &value1);
	YDB_ASSERT(YDB_OK == status);

	printf("# Test SimpleAPI functions for YDB_ERR_SIMPLEAPINOTALLOWED error\n"); fflush(stdout);
	status = ydb_data_s(&basevar, 0, NULL, &data_value); CHECK_STATUS("ydb_data_s()", status);
	status = ydb_delete_excl_s(0, NULL); CHECK_STATUS("ydb_delete_excl_s()", status);
	status = ydb_delete_s(&basevar, 0, NULL, YDB_DEL_NODE); CHECK_STATUS("ydb_delete_s()", status);
	status = ydb_get_s(&basevar, 0, NULL, &value2); CHECK_STATUS("ydb_get_s()", status);
	status = ydb_incr_s(&basevar, 0, NULL, NULL, &value2); CHECK_STATUS("ydb_incr_s()", status);
	status = ydb_lock_s(LOCK_TIMEOUT, 0); CHECK_STATUS("ydb_lock_s()", status);
	status = ydb_lock_decr_s(&basevar, 0, NULL); CHECK_STATUS("ydb_lock_decr_s()", status);
	status = ydb_lock_incr_s(LOCK_TIMEOUT, &basevar, 0, NULL); CHECK_STATUS("ydb_lock_incr_s()", status);
	status = ydb_node_next_s(&basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS("ydb_node_next_s()", status);
	status = ydb_node_previous_s(&basevar, 0, NULL, &dst_used, &value1); CHECK_STATUS("ydb_node_previous_s()", status);
	status = ydb_set_s(&basevar, 0, NULL, &value1); CHECK_STATUS("ydb_set_s()", status);
	status = ydb_str2zwr_s(&value1, &value2); CHECK_STATUS("ydb_str2zwr_s()", status);
	status = ydb_subscript_next_s(&basevar, 0, NULL, &value1); CHECK_STATUS("ydb_subscript_next_s()", status);
	status = ydb_subscript_previous_s(&basevar, 0, NULL, &value1); CHECK_STATUS("ydb_subscript_previous_s()", status);
	status = ydb_tp_s(NULL, NULL, NULL, 0, NULL); CHECK_STATUS("ydb_tp_s()", status);
	status = ydb_zwr2str_s(&value1, &value2); CHECK_STATUS("ydb_zwr2str_s()", status);

	status = ydb_child_init(NULL); CHECK_STATUS("ydb_child_init()", status);
	status = ydb_file_id_free(NULL); CHECK_STATUS("ydb_file_id_free()", status);
	status = ydb_file_is_identical(&fileid1, &fileid2); CHECK_STATUS("ydb_file_is_identical()", status);
	status = ydb_file_name_to_id(&filename, &fileid1); CHECK_STATUS("ydb_file_name_to_id()", status);
/*	To be fixed later: function returns error code that cannot be redirected
	printf(" --> Invoke ydb_fork_n_core()            after SimpleThreadAPI call : There is no return value since function is void\n"); fflush(stdout);
	ydb_fork_n_core();
*/
	printf(" --> Invoke ydb_free()                   after SimpleThreadAPI call : There is no return value since function is void\n"); fflush(stdout);
	ydb_free(&fileid1);
	status = ydb_hiber_start(time); CHECK_STATUS("ydb_hiber_start()", status);
	status = ydb_hiber_start_wait_any(time); CHECK_STATUS("ydb_hiber_start_wait_any()", status);
	status = ydb_init(); CHECK_STATUS("ydb_init()", status);
	ptr = ydb_malloc(size); CHECK_STATUS("ydb_malloc()", ptr);
	status = ydb_message(i, &value1); CHECK_STATUS("ydb_message()", status);
	status = ydb_stdout_stderr_adjust(); CHECK_STATUS("ydb_stdout_stderr_adjust()", status);
	status = ydb_thread_is_main();
	if (YDB_NOTOK == status)
	{
		printf(" --> Invoke ydb_thread_is_main()         after SimpleThreadAPI call : Return value is YDB_NOTOK as expected\n");
		fflush(stdout);
	} else
	{
		printf(" --> Invoke ydb_thread_is_main()	 after SimpleThreadAPI call : Return value is not YDB_NOTOK and something went wrong\n");
		fflush(stdout);
	}
	printf(" --> Invoke ydb_timer_cancel()           after SimpleThreadAPI call : There is no return value since function is void\n"); fflush(stdout);
	ydb_timer_cancel(timer_id);
	status = ydb_timer_start(timer_id, time, NULL, data_value, &valuebuff); CHECK_STATUS("ydb_timer_start()", status);
	status = ydb_exit(); CHECK_STATUS("ydb_exit()", status);

	return 0;
}
