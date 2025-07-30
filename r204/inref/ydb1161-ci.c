/****************************************************************
 *								*
 * Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>

#include "libyottadb.h"

uintptr_t table1, oldhandle1;

int main(void) {
	ci_name_descriptor routine1 = {{5, "ydb1161"}, NULL};
	int status;
	char errspace[1024];
	ydb_buffer_t errbuf = {sizeof(errspace), 0, errspace};
	pthread_t thread_id;
	int value1;

	printf("# ydb1161.c: Open an M call-in table, [table1.ci]\n");
	status = ydb_ci_tab_open_t(0, &errbuf, "table1.ci", &table1);
	if (status) printf("ydb_cip_tab_open error %.*s\n", errbuf.len_used, errbuf.buf_addr), exit(1);

	printf("# ydb1161.c: Switch to the open call-in table [table1.ci] using ydb_cip_tab_switch()\n");
	// Call M function the first time to cache the function lookup
	status = ydb_ci_tab_switch_t(0, &errbuf, table1, &oldhandle1);
	if (status) printf("ydb_cip_tab_switch error %.*s\n", errbuf.len_used, errbuf.buf_addr), exit(1);
	printf("# ydb1161.c: Call an M function, [ydb1161], from the open call-in table [table1.ci], causing the YDB SimpleAPI to cache it\n");
	status = ydb_cip_t(0, &errbuf, &routine1, &value1);
	if (status) printf("ydb_cip_t error %.*s\n", errbuf.len_used, errbuf.buf_addr), exit(1);

	printf("# ydb1161.c: Restore the open call-in table, [table1.ci]\n");
	status = ydb_ci_tab_switch_t(0, &errbuf, oldhandle1, &oldhandle1);

	printf("# ydb1161.c: Call the M function, [ydb1161], again to cause the YDB SimpleAPI to load it from the cache\n");
	printf("#            Expect no errors. Previously, this would issue a %%YDB-E-CITABENV error due to the SimpleAPI\n");
	printf("#            attempting to reload the M function from the restored call-in table, rather than the cache.\n");
	printf("#            The previous workaround was to skip the above ydb_ci_tab_switch_t() to avoid this error.\n");
	status = ydb_cip_t(0, &errbuf, &routine1, &value1);
	if (status) {
		printf("ydb_cip_t error %.*s\n", errbuf.len_used, errbuf.buf_addr);
		exit(1);
	} else {
		printf("PASS: No %%YDB-E-CITABENV error issued\n");
	}
}
