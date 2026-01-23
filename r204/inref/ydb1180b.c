/****************************************************************
 *								*
 * Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

/* Used to test that ydb_cip_t() will clear the error buffer after being called.
 * ydb_ci_t() will run a mumps routine. In this case the mumps code will divide by 0, putting it in an
 * error state. If the error buffer is properly cleared, than after running that, when my sleep triggers a
 * TPTIMEOUT error. However, if the buffer was not properly cleared than the code will think it is still in
 * an error state and no TPTIMEOUT error will occur.
 */
#include <stdio.h>
#include <unistd.h>

#include "libyottadb.h"

char	errbuf[1024];

int mysleep(uint64_t tptoken, ydb_buffer_t *errstr, void *param);

int	main()
{
	int		status, max_buff_len;
	ydb_buffer_t	isv, value, err_out;
	ydb_tp2fnptr_t	tpfn;

	max_buff_len = 500;
	err_out.buf_addr = malloc(max_buff_len);
	err_out.len_alloc = max_buff_len;
	err_out.len_used = 0;
	ydb_ci_t(YDB_NOTTP, &err_out, "ydb1180mb");
	printf("%.*s\n", err_out.len_used, err_out.buf_addr);
	YDB_LITERAL_TO_BUFFER("$ZMAXTPTIME", &isv);
	YDB_LITERAL_TO_BUFFER("1", &value);
	ydb_set_st(YDB_NOTTP, NULL, &isv, 0, NULL, &value);

	tpfn = &mysleep;
	status = ydb_tp_st(YDB_NOTTP, NULL, tpfn, NULL, NULL, 0, NULL);
	free(err_out.buf_addr);
	if (YDB_OK != status)
	{
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_tp_st() : status = %d : %s\n", status, errbuf);
		return status;
	}
}

int mysleep(uint64_t tptoken, ydb_buffer_t *errstr, void *param)
{
	int		i;
	ydb_buffer_t	tmp;
	int		status;

	YDB_LITERAL_TO_BUFFER("TMP", &tmp);
	/* 4 iterations of 0.5 seconds each for a total of 2 second sleep that is greater than 1 second $ZMAXTPTIME */
	for (i = 0; i < 4; i++)
	{
		status = ydb_set_st(tptoken, errstr, &tmp, 0, NULL, NULL);
		if (YDB_OK != status)
			return status;
		usleep(500000);	/* sleep for 0.5 seconds */
	}
}
