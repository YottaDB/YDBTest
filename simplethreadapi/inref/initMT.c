#include <stdio.h>
#include <pthread.h>
#include "libyottadb.h"

#define NUM_THREADS 8

void *childThread(void *tArgs);

/* Creates NUM_THREADS and calls childThread
 * then checks the return value for the expected YDB_OK
 */
int main(){
	int status;
	pthread_t threads[NUM_THREADS];
	char errbuf[2048];

	/* initialize the SimpleThreadAPI library */
	printf("Calling ydb_get_st() to get the process in SimpleThreadAPI mode\n");
	ydb_buffer_t basevar, outvalue;
	YDB_LITERAL_TO_BUFFER("$TLEVEL", &basevar);
	YDB_MALLOC_BUFFER(&outvalue, 5);
	status = ydb_get_st(YDB_NOTTP, NULL, &basevar, 0, NULL, &outvalue);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_init();
	if(status == YDB_OK){
		printf("ydb_init() correctly returns YDB_OK in main thread\n");
	} else {	
		ydb_zstatus(errbuf, sizeof(errbuf));
		printf("ydb_init() is not returning YDB_OK in main thread\nReturned: %s\n", errbuf);
	}

	printf("Testing ydb_init() works properly when called concurrently\n");

	int i;
	printf("Creating %d threads\n", NUM_THREADS);
	for(i = 0; i < NUM_THREADS; ++i){
		status = pthread_create(&threads[i], NULL, childThread, NULL);
		YDB_ASSERT(status == 0);
	}

	for(i = 0; i < NUM_THREADS; ++i){
		void *retValue;
		status = pthread_join(threads[i], &retValue);
		YDB_ASSERT(status == 0);
		if((intptr_t) retValue == YDB_OK){
			printf("Thread %d: PASS ydb_init() returned YDB_OK as expected\n", i);
		} else {
			ydb_zstatus(errbuf, sizeof(errbuf));
			printf("Thread %d: FAIL\nReturned: %s\n", i, errbuf);
		}
	}

	return 0;
}

/* calls ydb_init()
 * then returns it's status
 */
void *childThread(void *tArgs){
	int status;
	status = ydb_init();	
	return (void *)(intptr_t)status;
}
