/****************************************************************
 *								*
 * Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries. *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <gtmxc_types.h>
#include <stdio.h>

int main() {
  int	status;
  char	errbuf[1024];

  ydb_init();

  printf("Call-in to echo()\n"); fflush(stdout);
  status = ydb_ci("echo");
  if (YDB_OK != status)
  {
  	ydb_zstatus(errbuf, 1024);
	printf("echo(): %s\n", errbuf);
	fflush(stdout);
  }
  printf("Call-in to test1()\n"); fflush(stdout);
  status = ydb_ci("test1", "abcd");
  if (YDB_OK != status)
  {
  	ydb_zstatus(errbuf, 1024);
	printf("test1(): %s\n", errbuf);
	fflush(stdout);
  }
  printf("Call-in to call()\n"); fflush(stdout);
  status = ydb_ci("call");
  if (YDB_OK != status)
  {
  	ydb_zstatus(errbuf, 1024);
	printf("call(): %s\n", errbuf);
	fflush(stdout);
  }
  status = ydb_exit();
  YDB_ASSERT(!status);
  return 0;
}
