#include <stdio.h>
#include <string.h>
#include "libyottadb.h"

int initFn();

/* uses ydb_tp_s() to call ydb_init()
 * ydb_tp_s should return YDB_OK
 * then checks that initFn()
 */
int main(){
	ydb_tpfnptr_t initPtr;
	int status;

	initPtr = &initFn;
	status = ydb_tp_s(initPtr, NULL, NULL, 0, NULL);
	YDB_ASSERT(status == YDB_OK);
	printf("ydb_tp_s() returned YDB_OK as expected\n");

	return 0;
}

/* is called by ydb_tp_s()
 * calls ydb_init() and checks its status
 * which should be YDB_OK
 */
int initFn(){
	int status;
	char errbuf[2048];

	/* ydb_init check */
	status = ydb_init();
	if(status == YDB_OK){
		printf("ydb_init() inside ydb_tp_s() returned YDB_OK as expected\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_init() returned wrong error code: %s\nShould have been: YDB_OK\n", errbuf);
	}

	return 0;
}
