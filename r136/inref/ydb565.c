/****************************************************************
 *								*
 * Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include "libyottadb.h"

#define	ERRBUF_SIZE	1024
#define	RESET_BUFF(BUFF, BUF) BUFF.buf_addr = BUF; BUFF.len_alloc = sizeof(BUF); BUFF.len_used = 0

int main(int argc, char *argv[])
{
	ydb_buffer_t	ibuff, obuff, iobuff, retbuff;
	char		ibuf[256], obuf[256], iobuf[512], retbuf[1024];
	int		status;
	char		errbuf[ERRBUF_SIZE];
	uintptr_t	ci_tab_handle_new;

	RESET_BUFF(ibuff, ibuf);
	RESET_BUFF(obuff, obuf);
	RESET_BUFF(iobuff, iobuf);
	RESET_BUFF(retbuff, retbuf);

	printf("# Test that I ydb_buffer_t parameter with len_used more than 1MiB issues a MAXSTRLEN error\n");
	ibuff.len_alloc = ibuff.len_used = 0x100000 + 1;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_MAXSTRLEN != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_MAXSTRLEN. Got: %d; Expected: %d\n", status, YDB_ERR_MAXSTRLEN);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_MAXSTRLEN\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(ibuff, ibuf);

	printf("# Test that I ydb_buffer_t parameter with len_used more than len_alloc issues a PARAMINVALID error\n");
	ibuff.len_used = 0x100000 + 1;
	ibuff.len_alloc = 0x100000;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_PARAMINVALID != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_PARAMINVALID. Got: %d; Expected: %d\n", status, YDB_ERR_PARAMINVALID);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_PARAMINVALID\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(ibuff, ibuf);

	printf("# Test that I ydb_buffer_t parameter with len_used more than 0 but buf_addr == NULL issues a PARAMINVALID error\n");
	ibuff.len_used = 1;
	ibuff.buf_addr = NULL;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_PARAMINVALID != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_PARAMINVALID. Got: %d; Expected: %d\n", status, YDB_ERR_PARAMINVALID);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_PARAMINVALID\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(ibuff, ibuf);

	printf("# Test that IO ydb_buffer_t parameter with len_used more than 1MiB issues a MAXSTRLEN error\n");
	iobuff.len_alloc = iobuff.len_used = 0x100000 + 1;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_MAXSTRLEN != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_MAXSTRLEN. Got: %d; Expected: %d\n", status, YDB_ERR_MAXSTRLEN);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_MAXSTRLEN\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(iobuff, iobuf);

	printf("# Test that IO ydb_buffer_t parameter with len_used more than len_alloc issues a PARAMINVALID error\n");
	iobuff.len_used = 0x100000 + 1;
	iobuff.len_alloc = 0x100000;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_PARAMINVALID != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_PARAMINVALID. Got: %d; Expected: %d\n", status, YDB_ERR_PARAMINVALID);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_PARAMINVALID\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(iobuff, iobuf);

	printf("# Test that IO ydb_buffer_t parameter with len_used more than 0 but buf_addr == NULL issues a PARAMINVALID error\n");
	iobuff.len_used = 1;
	iobuff.buf_addr = NULL;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_PARAMINVALID != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_PARAMINVALID. Got: %d; Expected: %d\n", status, YDB_ERR_PARAMINVALID);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_PARAMINVALID\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(iobuff, iobuf);

	printf("# Test that IO ydb_buffer_t parameter with output value more than len_alloc issues a INVSTRLEN error\n");
	iobuff.len_used = iobuff.len_alloc;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_INVSTRLEN != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_INVSTRLEN. Got: %d; Expected: %d\n", status, YDB_ERR_INVSTRLEN);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_INVSTRLEN\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(iobuff, iobuf);

	printf("# Test that O ydb_buffer_t parameter with len_used more than 1MiB does NOT issue a MAXSTRLEN error\n");
	obuff.len_alloc = obuff.len_used = 0x100000 + 1;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_OK != status) {
		printf("FAIL: ydb_ci() did not return YDB_OK. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci() returned YDB_OK\n");
	}
	RESET_BUFF(obuff, obuf);

	printf("# Test that O ydb_buffer_t parameter with len_used more than len_alloc does NOT issue a PARAMINVALID error\n");
	obuff.len_used = 0x100000 + 1;
	obuff.len_alloc = 0x100000;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_OK != status) {
		printf("FAIL: ydb_ci() did not return YDB_OK. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci() returned YDB_OK\n");
	}
	RESET_BUFF(obuff, obuf);

	printf("# Test that O ydb_buffer_t parameter with len_used more than 0 but buf_addr == NULL does NOT issue a PARAMINVALID error\n");
	obuff.len_used = 1;
	obuff.buf_addr = NULL;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_OK != status) {
		printf("FAIL: ydb_ci() did not return YDB_OK. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci() returned YDB_OK\n");
	}
	RESET_BUFF(obuff, obuf);

	printf("# Test that O ydb_buffer_t parameter with output len_used more than 0 but buf_addr == NULL does issue a PARAMINVALID error\n");
	ibuf[0] = 'a'; ibuff.len_used = 1;
	obuff.buf_addr = NULL;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_PARAMINVALID != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_PARAMINVALID. Got: %d; Expected: %d\n", status, YDB_ERR_PARAMINVALID);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_PARAMINVALID\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(obuff, obuf);
	RESET_BUFF(ibuff, ibuf);

	printf("# Test that O ydb_buffer_t parameter with output value more than len_alloc issues a INVSTRLEN error\n");
	ibuff.len_used = ibuff.len_alloc; /* set ibuff here since obuff return value is double ibuff size */
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_INVSTRLEN != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_INVSTRLEN. Got: %d; Expected: %d\n", status, YDB_ERR_INVSTRLEN);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_INVSTRLEN\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(ibuff, ibuf);

	printf("# Test that RETURN ydb_buffer_t parameter with len_used more than 1MiB does NOT issue a MAXSTRLEN error\n");
	obuff.len_alloc = obuff.len_used = 0x100000 + 1;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_OK != status) {
		printf("FAIL: ydb_ci() did not return YDB_OK. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci() returned YDB_OK\n");
	}
	RESET_BUFF(obuff, obuf);

	printf("# Test that RETURN ydb_buffer_t parameter with len_used more than len_alloc does NOT issue a PARAMINVALID error\n");
	obuff.len_used = 0x100000 + 1;
	obuff.len_alloc = 0x100000;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_OK != status) {
		printf("FAIL: ydb_ci() did not return YDB_OK. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci() returned YDB_OK\n");
	}
	RESET_BUFF(obuff, obuf);

	printf("# Test that RETURN ydb_buffer_t parameter with len_used more than 0 but buf_addr == NULL does NOT issue a PARAMINVALID error\n");
	obuff.len_used = 1;
	obuff.buf_addr = NULL;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_OK != status) {
		printf("FAIL: ydb_ci() did not return YDB_OK. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci() returned YDB_OK\n");
	}
	RESET_BUFF(obuff, obuf);

	printf("# Test that RETURN ydb_buffer_t parameter with return len_used more than 0 but buf_addr == NULL does issue a PARAMINVALID error\n");
	ibuf[0] = 'a'; ibuff.len_used = 1;
	retbuff.buf_addr = NULL;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_PARAMINVALID != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_PARAMINVALID. Got: %d; Expected: %d\n", status, YDB_ERR_PARAMINVALID);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_PARAMINVALID\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(retbuff, retbuf);
	RESET_BUFF(ibuff, ibuf);

	printf("# Test that RETURN ydb_buffer_t parameter with return value more than len_alloc issues a INVSTRLEN error\n");
	ibuff.len_used = ibuff.len_alloc / 2;
	iobuff.len_used = iobuff.len_alloc / 2;
	retbuff.len_alloc = retbuff.len_alloc / 2;
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_ERR_INVSTRLEN != status) {
		printf("FAIL: ydb_ci() did not return YDB_ERR_INVSTRLEN. Got: %d; Expected: %d\n", status, YDB_ERR_INVSTRLEN);
	} else {
		printf("PASS: ydb_ci() returned YDB_ERR_INVSTRLEN\n");
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("%s\n", errbuf);
	}
	RESET_BUFF(ibuff, ibuf);
	RESET_BUFF(iobuff, iobuf);

	printf("# Test one valid ydb_ci call with ydb_buffer_t * parameters of I, IO, O and return value\n");
	strcpy(ibuf, "abc");
	ibuff.len_used = strlen(ibuf);
	strcpy(iobuf, "defgh");
	iobuff.len_used = strlen(iobuf);
	status = ydb_ci("retBuff", &retbuff, &ibuff, &obuff, &iobuff);
	if (YDB_OK != status) {
		printf("FAIL: ydb_ci() did not return YDB_OK. Got: %d; Expected: %d\n", status, YDB_OK);
	} else {
		printf("PASS: ydb_ci() returned YDB_OK\n");
		printf("# Listing below the contents of ibuf, obuf, iobuf, retbuf to be included in reference file\n");
		printf("ibuf = %.*s\n", ibuff.len_used, ibuff.buf_addr);
		printf("iobuf = %.*s\n", iobuff.len_used, iobuff.buf_addr);
		printf("obuf = %.*s\n", obuff.len_used, obuff.buf_addr);
		printf("retbuf = %.*s\n", retbuff.len_used, retbuff.buf_addr);
	}
	RESET_BUFF(ibuff, ibuf);
	RESET_BUFF(iobuff, iobuf);

	printf("# Test that [ydb_buffer_t **] is not accepted as return type in call-in\n");
	status = ydb_ci_tab_open("err1.ci", &ci_tab_handle_new);
	if (YDB_OK != status) {
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Failure of ydb_ci_tab_open with error: %s\n", errbuf);
	}

	printf("# Test that [ydb_buffer_t] is not accepted as return type in call-in\n");
	status = ydb_ci_tab_open("err2.ci", &ci_tab_handle_new);
	if (YDB_OK != status) {
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Failure of ydb_ci_tab_open with error: %s\n", errbuf);
	}

	printf("# Test that [ydb_buffer_t **] is not accepted as O parameter type in call-in\n");
	status = ydb_ci_tab_open("err3.ci", &ci_tab_handle_new);
	if (YDB_OK != status) {
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Failure of ydb_ci_tab_open with error: %s\n", errbuf);
	}

	printf("# Test that [ydb_buffer_t] is not accepted as O parameter type in call-in\n");
	status = ydb_ci_tab_open("err4.ci", &ci_tab_handle_new);
	if (YDB_OK != status) {
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Failure of ydb_ci_tab_open with error: %s\n", errbuf);
	}

	printf("# Test that [ydb_buffer_t **] is not accepted as I parameter type in call-in\n");
	status = ydb_ci_tab_open("err5.ci", &ci_tab_handle_new);
	if (YDB_OK != status) {
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Failure of ydb_ci_tab_open with error: %s\n", errbuf);
	}

	printf("# Test that [ydb_buffer_t] is not accepted as I parameter type in call-in\n");
	status = ydb_ci_tab_open("err6.ci", &ci_tab_handle_new);
	if (YDB_OK != status) {
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Failure of ydb_ci_tab_open with error: %s\n", errbuf);
	}

	printf("# Test that [ydb_buffer_t **] is not accepted as IO parameter type in call-in\n");
	status = ydb_ci_tab_open("err7.ci", &ci_tab_handle_new);
	if (YDB_OK != status) {
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Failure of ydb_ci_tab_open with error: %s\n", errbuf);
	}

	printf("# Test that [ydb_buffer_t] is not accepted as IO parameter type in call-in\n");
	status = ydb_ci_tab_open("err8.ci", &ci_tab_handle_new);
	if (YDB_OK != status) {
		ydb_zstatus(errbuf, ERRBUF_SIZE);
		printf("Failure of ydb_ci_tab_open with error: %s\n", errbuf);
	}

	return 0;
}
