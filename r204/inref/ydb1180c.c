/****************************************************************
 *								*
 * Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	*
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

#include "libyottadb.h"
#include "gtmxc_types.h"

/* Used by ydb1180 test to invoke ydb_cip and gtm_cip and ensure the $ECODE
 * will be cleared before each invocation.
 * ydb1180ma will cause a zero division error, setting $ECODE.
 * ydb1180WE will print the value of $ECODE.
 * If $ECODE is empty, we know it was properly cleared.
 */
int main()
{
	/* ydb1180ma.m, a program that will cause an error, used to set $ECODE. */
	char	cause_error_str[] = "ydb1180ma";
	int	cause_error_str_len = strlen(cause_error_str);
	/* ydb1180WE.m(write ecode) a program that we will use to write the current value of $ECODE*/
	char	write_ecode_str[] = "ydb1180WE";
	int	write_ecode_str_len = strlen(write_ecode_str);
	ci_name_descriptor cause_error;
	ci_name_descriptor write_ecode;

	/* The length parameters in the ci_name_descriptor->rtn_name.length are unnecessary.
	 * ydb_cip assumes rtn_name.address is null terminated and ignores rtn_name.length.
	 * We fill it in anyway to be safe.
	 */
	cause_error.rtn_name.address = cause_error_str;
	cause_error.rtn_name.length = cause_error_str_len;
	cause_error.handle = NULL;
	write_ecode.rtn_name.address = write_ecode_str;
	write_ecode.rtn_name.length = write_ecode_str_len;
	write_ecode.handle = NULL;
	/* Cause an error with ydb_cip. */
	ydb_cip(&cause_error);
	/* Check that $ECODE is empty in the next call. */
	ydb_cip(&write_ecode);
	/* Cause an error with gtm_cip. */
	gtm_cip(&cause_error);
	/* Check that $ECODE is empty in the next call. */
	gtm_cip(&write_ecode);
}
