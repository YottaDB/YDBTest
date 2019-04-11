#include <stdio.h>
#include <string.h>
#include "libyottadb.h"

int exitFn();

/* uses ydb_tp_st() to call ydb_exit()
 * ydb_tp_st should return YDB_OK
 * then checks that exitFn()
 * was called properly using ydb_get_st()
 */
int main(){
	ydb_tp2fnptr_t exitPtr;
	int status;

	exitPtr = &exitFn;
	status = ydb_tp_st(YDB_NOTTP, NULL, exitPtr, NULL, "ID", 0, NULL);
	YDB_ASSERT(status == YDB_OK);
	printf("ydb_tp_st() returned YDB_OK as expected\n");

	ydb_buffer_t basevar, outvalue;
	char errbuf[2048];
	char outbuf[64];
	outvalue.buf_addr = &outbuf[0];
	outvalue.len_used = 0;
	outvalue.len_alloc = sizeof(outbuf);
	YDB_LITERAL_TO_BUFFER("^a", &basevar);

	status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &outvalue);
	outvalue.buf_addr[outvalue.len_used] = '\0';
	if(strcmp(outvalue.buf_addr, "qwerty") == 0){
		printf("ydb_get_st() still works\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_get_st() failed with error code: %s\nShould have been: YDB_OK\n", errbuf);
	}
	return 0;
}

/* is called by ydb_tp_st()
 * calls ydb_exit() and checks its status
 * which should be -YBD_ERR_INVYDBEXIT
 * also performs a ydb_set_st()
 * to check that the tp is intact
 */
int exitFn(uint64_t tptoken, ydb_buffer_t *errstr){
	int status;
	char errbuf[2048];

	/* ydb_exit check */
	status = ydb_exit();
	if(status == -YDB_ERR_INVYDBEXIT){
		printf("ydb_exit() inside ydb_tp_st() returned -YDB_ERR_INVYDBEXIT as expected\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_exit() returned wrong error code: %s\nShould have been: -YDB_ERR_INVYDBEXIT\n", errbuf);
	}

	/* checks that the tp still works */
	ydb_buffer_t basevar, value;
	YDB_LITERAL_TO_BUFFER("^a", &basevar);
	YDB_LITERAL_TO_BUFFER("qwerty", &value);

	status = ydb_set_st(tptoken, errstr, &basevar, 0, NULL, &value);
	if(status == YDB_OK){
		printf("ydb_set_st() still works\n");
	} else {
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_set_st() failed with error code: %s\nShould have been: YDB_OK\n", errbuf);
	}
	return 0;
}
