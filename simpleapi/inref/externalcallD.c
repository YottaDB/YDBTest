#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "libyottadb.h"

#define printff(format, ...) ({\
			printf(format, ## __VA_ARGS__);\
			fflush(stdout);\
			})

/* driver for the rest of the test
 * just calls the M code which then calls the C code
 */
int main(){

	/* simpleapi functions */
	printff("ydb_set_s(): ");
	ydb_ci("mSet");

	printff("ydb_data_s(): ");
	ydb_ci("mData");

	printff("ydb_get_s(): ");
	ydb_ci("mGet");

	printff("ydb_incr_s(): ");
	ydb_ci("mIncr");

	printff("ydb_node_next_s(): ");
	ydb_ci("mNodeNext");

	printff("ydb_node_previous_s(): ");
	ydb_ci("mNodePrev");

	printff("ydb_str2zwr_s(): ");
	ydb_ci("mStr2zwr");

	printff("ydb_zwr2srt_s(): ");
	ydb_ci("mZwr2str");

	printff("ydb_subscript_next_s(): ");
	ydb_ci("mSubNext");

	printff("ydb_subscript_previous_s(): ");
	ydb_ci("mSubPrev");

	printff("ydb_delete_s(): ");
	ydb_ci("mDelete");

	printff("ydb_delete_excl_s(): ");
	ydb_ci("mDeleteExcl");

	printff("ydb_tp_s(): ");
	ydb_ci("mTp");

	printff("ydb_lock_s(): ");
	ydb_ci("mLock");

	printff("ydb_lock_incr_s(): ");
	ydb_ci("mLockIncr");

	printff("ydb_lock_decr_s(): ");
	ydb_ci("mLockDecr");


	/* utility functions */
	
	printff("ydb_file_name_to_id(): ");
	ydb_ci("mFileid");

	printff("ydb_file_is_identical(): ");
	ydb_ci("mFileIdent");

	printff("ydb_file_id_free(): ");
	ydb_ci("mFileFree");

	if(strcmp(getenv("tst_image"), "pro") == 0){
		printff("Pro build, calling ydb_fork_n_core()\n");
		ydb_ci("mFNC");
	} else {
		printff("Debug build, skipping ydb_fork_n_core()\n");
	}

	printff("ydb_hiber_start(): ");
	ydb_ci("mHiber");

	printff("ydb_hiber_start_wait_any(): ");
	ydb_ci("mHiberW");

	printff("ydb_malloc(): ");
	ydb_ci("mMal");

	printff("ydb_free(): ");
	ydb_ci("mFree");

	printff("ydb_message(): ");
	ydb_ci("mMsg");

	printff("ydb_thread_is_main(): ");
	ydb_ci("mMT");

	printff("ydb_timer_start() (timer should trigger): ");
	ydb_ci("mTimerS");

	printff("ydb_timer_cancel() (timer should not trigger): ");
	ydb_ci("mTimerC");

	printff("ydb_exit(): ");
	ydb_ci("mExit");

	printff("ydb_ci(): ");
	ydb_ci("mCi");

	printff("ydb_cip(): ");
	ydb_ci("mCip");

	printff("ydb_ci_tab_open(): ");
	ydb_ci("mCiTab");

	printff("ydb_ci_tab_swtich(): ");
	ydb_ci("mCiSwitch");

	return 0;
}
