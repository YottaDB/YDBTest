#include <stdio.h>
#include <pthread.h>
#include "libyottadb.h"

#define NUM_THREADS 8

void *childThread(void *tArgs);

/* Creates NUM_THREADS and calls childThread
 * then checks the return value for the expected YDB_NOTOK
 */
int main(){
	int status;
	pthread_t threads[NUM_THREADS];

	/* initialize the SimpleAPI library */
	ydb_buffer_t basevar, outvalue;
	YDB_LITERAL_TO_BUFFER("$TLEVEL", &basevar);
	YDB_MALLOC_BUFFER(&outvalue, 5);
	status = ydb_get_s(&basevar, 0, NULL, &outvalue);
	YDB_ASSERT(status == YDB_OK);
	status = ydb_thread_is_main();
	if(status == YDB_OK){
		printf("ydb_thread_is_main() is correctly return YDB_OK in main thread\n");
	} else {	
		printf("ydb_thread_is_main() is not returning YBD_OK in main thread\n");
	}

	printf("Testing ydb_thread_is_main() works properly when called concurrently\n");

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
		if((intptr_t) retValue == YDB_NOTOK){
			printf("Thread %d: PASS ydb_thread_is_main() returned YDB_NOTOK as expected\n", i);
		} else {
			printf("Thread %d: FAIL\n", i);
		}
	}

	return 0;
}

/* calls ydb_thread_is_main()
 * then returns it's status
 */
void *childThread(void *tArgs){
	int status;
	status = ydb_thread_is_main();	
	return (void *)(intptr_t)status;
}
