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
#include <stdio.h>

#define ERRBUF_SIZE 	1024

#define FILE1		"utils_file_HL.txt"
#define FILE2		"utils_file_SL.txt"
#define FILE3		"utils_file_1.txt"
#define FILE4		"utils_file_2.txt"
#define FILE5		"utils_file_SL2.txt"

int main()
{
	int			status;
	ydb_string_t		file1, file2, file3, file4, file5;
	ydb_fileid_ptr_t	file1ptr, file2ptr;
	char			errbuf[ERRBUF_SIZE];

	file1.address = FILE1;
	file1.length = sizeof(file1.address) - 1;
	file2.address = FILE2;
	file2.length = sizeof(file2.address) - 1;
	file3.address = FILE3;
	file3.length = sizeof(file3.address) - 1;
	file4.address = FILE4;
	file4.length = sizeof(file4.address) - 1;
	file5.address = FILE5;
	file5.length = sizeof(file5.address) - 1;

	printf("\n### Test Functionality of ydb_file_name_to_id_t(), ydb_file_is_identical_t(), and ydb_file_id_free_t() ###\n");
	fflush(stdout);

	printf("\n## Test 1: Two files assigned to two fileid ##\n"); fflush(stdout);
	printf("# Convert the file names to IDs using ydb_file_name_to_id_t()\n"); fflush(stdout);
	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file3, &file1ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}

	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file4, &file2ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Compare the two fileid using ydb_file_is_identical_t(), should return YDB_NOTOK\n"); fflush(stdout);
	status = ydb_file_is_identical_t(YDB_NOTTP, NULL, file1ptr, file2ptr);
	if (YDB_OK == status)
	{
		printf("ydb_file_is_identical_t() returned YDB_OK (Files are identical)\n");
		fflush(stdout);
	} else if (YDB_NOTOK == status)
	{
		printf("ydb_file_is_identical_t() returned YDB_NOTOK (Files are not identical)\n");
		fflush(stdout);
	} else
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_is_identical[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Use ydb_file_id_free_t() to free the memory of the fileid used\n"); fflush(stdout);
	status = ydb_file_id_free_t(YDB_NOTTP, NULL,  file1ptr );
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_file_id_free_t(YDB_NOTTP, NULL,  file2ptr );
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}

	printf("\n## Test 2: Two files, one as a soft link to the other ##\n"); fflush(stdout);
	printf("# Convert the file names to IDs using ydb_file_name_to_id_t()\n"); fflush(stdout);
	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file1, &file1ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}

	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file2, &file2ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Compare the two fileid using ydb_file_is_identical_t(), should return YDB_OK\n"); fflush(stdout);
	status = ydb_file_is_identical_t(YDB_NOTTP, NULL, file1ptr, file2ptr);
	if (YDB_OK == status)
	{
		printf("ydb_file_is_identical_t() returned YDB_OK (Files are identical)\n");
		fflush(stdout);
	} else if (YDB_NOTOK == status)
	{
		printf("ydb_file_is_identical_t() returned YDB_NOTOK (Files are not identical)\n");
		fflush(stdout);
	} else
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_is_identical[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Use ydb_file_id_free_t() to free the memory of the fileid used\n"); fflush(stdout);
	status = ydb_file_id_free_t(YDB_NOTTP, NULL,  file1ptr );
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_file_id_free_t(YDB_NOTTP, NULL,  file2ptr );
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}

	printf("\n## Test 3: Two soft links which link to the same file ##\n"); fflush(stdout);
	printf("# Convert the file names to IDs using ydb_file_name_to_id_t()\n"); fflush(stdout);
	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file2, &file1ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}

	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file5, &file2ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Compare the two fileid using ydb_file_is_identical_t(), should return YDB_OK\n"); fflush(stdout);
	status = ydb_file_is_identical_t(YDB_NOTTP, NULL, file1ptr, file2ptr);
	if (YDB_OK == status)
	{
		printf("ydb_file_is_identical_t() returned YDB_OK (Files are identical)\n");
		fflush(stdout);
	} else if (YDB_NOTOK == status)
	{
		printf("ydb_file_is_identical_t() returned YDB_NOTOK (Files are not identical)\n");
		fflush(stdout);
	} else
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_is_identical[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Use ydb_file_id_free_t() to free the memory of the fileid used\n"); fflush(stdout);
	status = ydb_file_id_free_t(YDB_NOTTP, NULL,  file1ptr );
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_file_id_free_t(YDB_NOTTP, NULL,  file2ptr );
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}

	printf("\n## Test 4: One file assigned to two different fileid ##\n"); fflush(stdout);
	printf("# Convert the file names to IDs using ydb_file_name_to_id_t()\n"); fflush(stdout);
	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file1, &file1ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}

	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file1, &file2ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Compare the two fileid using ydb_file_is_identical_t(), should return YDB_OK\n"); fflush(stdout);
	status = ydb_file_is_identical_t(YDB_NOTTP, NULL, file1ptr, file2ptr);
	if (YDB_OK == status)
	{
		printf("ydb_file_is_identical_t() returned YDB_OK (Files are identical)\n");
		fflush(stdout);
	} else if (YDB_NOTOK == status)
	{
		printf("ydb_file_is_identical_t() returned YDB_NOTOK (Files are not identical)\n");
		fflush(stdout);
	} else
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_is_identical[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	printf("# Use ydb_file_id_free_t() to free the memory of the fileid used\n"); fflush(stdout);
	status = ydb_file_id_free_t(YDB_NOTTP, NULL,  file1ptr );
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}
	status = ydb_file_id_free_t(YDB_NOTTP, NULL,  file2ptr );
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
		return YDB_OK;
	}

	printf("\n### Test error scenarios for ydb_file_name_to_id_t(), ydb_file_is_identical_t(), and ydb_file_id_free_t() ###\n");
	fflush(stdout);

	printf("\n## Test of PARAMINVALID error ##\n"); fflush(stdout);
	printf("# Attempting ydb_file_name_to_id_t() with *filename = NULL\n"); fflush(stdout);
	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, NULL, &file1ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Attempting ydb_file_name_to_id_t() with *fileid = NULL\n"); fflush(stdout);
	status = ydb_file_name_to_id_t(YDB_NOTTP, NULL, &file1, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_name_to_id[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Attempting ydb_file_is_identical_t() with fileid1 = NULL\n"); fflush(stdout);
	status = ydb_file_is_identical_t(YDB_NOTTP, NULL, NULL, file2ptr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_is_identical[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Attempting ydb_file_is_identical_t() with fileid2 = NULL\n"); fflush(stdout);
	status = ydb_file_is_identical_t(YDB_NOTTP, NULL, file1ptr, NULL);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_is_identical[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}

	printf("# Attempting ydb_file_id_free_t() with fileid = NULL\n"); fflush(stdout);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("ydb_file_id_free[%d]: %s\n", __LINE__, errbuf);
		fflush(stdout);
	}
	return YDB_OK;
}
