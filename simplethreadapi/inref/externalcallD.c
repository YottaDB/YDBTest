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
	printff("ydb_set_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mSet");

	printff("ydb_data_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mData");

	printff("ydb_get_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mGet");

	printff("ydb_incr_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mIncr");

	printff("ydb_node_next_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mNodeNext");

	printff("ydb_node_previous_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mNodePrev");

	printff("ydb_str2zwr_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mStr2zwr");

	printff("ydb_zwr2srt_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mZwr2str");

	printff("ydb_subscript_next_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mSubNext");

	printff("ydb_subscript_previous_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mSubPrev");

	printff("ydb_delete_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mDelete");

	printff("ydb_delete_excl_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mDeleteExcl");

	printff("ydb_tp_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mTp");

	printff("ydb_lock_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mLock");

	printff("ydb_lock_incr_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mLockIncr");

	printff("ydb_lock_decr_st(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mLockDecr");


	/* utility functions */
	
	printff("ydb_file_name_to_id_t(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mFileid");

	printff("ydb_file_is_identical_t(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mFileIdent");

	printff("ydb_file_id_free_t(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mFileFree");

	if(strcmp(getenv("tst_image"), "pro") == 0){
		printff("Pro build, calling ydb_fork_n_core()\n");
		ydb_ci_t(YDB_NOTTP, NULL, "mFNC");
	} else {
		printff("Debug build, skipping ydb_fork_n_core()\n");
	}

	printff("ydb_hiber_start(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mHiber");

	printff("ydb_hiber_start_wait_any(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mHiberW");

	printff("ydb_malloc(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mMal");

	printff("ydb_free(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mFree");

	printff("ydb_message_t(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mMsg");

	printff("ydb_thread_is_main(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mMT");

	printff("ydb_timer_start_t() (timer should trigger): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mTimerS");

	printff("ydb_timer_cancel_t() (timer should not trigger): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mTimerC");

	printff("ydb_exit(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mExit");

	printff("ydb_ci_t(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mCi");

	printff("ydb_cip_t(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mCip");

	printff("ydb_ci_tab_open_t(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mCiTab");

	printff("ydb_ci_tab_swtich_t(): ");
	ydb_ci_t(YDB_NOTTP, NULL, "mCiSwitch");

	return 0;
}
