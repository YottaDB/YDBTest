/****************************************************************
 *								*
 * Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	*
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/

#include <assert.h>
#include <stdio.h>
#include <libyottadb.h>

static int first_run = 1;

// This returns YDB_TP_RESTART the first time it is run, and YDB_OK all other times.
int inner_trans(uint64_t tptoken, ydb_buffer_t *errstr, void *ignore_me) {
    if (first_run) {
        puts("inner_trans : Running inner transaction : First try : Returning YDB_TP_RESTART");
        first_run = 0;
        return YDB_TP_RESTART;
    } else {
        puts("inner_trans : Running inner transaction : Second try : Returning YDB_OK");
        return YDB_OK;
    }
}

// This verifies the inner transaction works properly.
int outer_trans(uint64_t tptoken, ydb_buffer_t *errstr, void *ignore_me) {
    int	captured_first_run, status;

    captured_first_run = first_run;
    printf("outer_trans : Running outer transaction : %s try\n", (captured_first_run ? "First" : "Second"));
    status = ydb_tp_st(tptoken, errstr, inner_trans, NULL, "BATCH", 0, NULL);
    puts("outer_trans : Finished inner transaction");
    if (captured_first_run) {
        assert(status == YDB_TP_RESTART);
        puts("outer_trans : Finished First try, Returning YDB_TP_RESTART");
    } else {
        assert(status == YDB_OK);
        puts("outer_trans : Finished Second try, Returning YDB_OK");
    }
    return status;
}

int main() {
    int	status;

    puts("main : Starting outer transaction");
    status = ydb_tp_st(YDB_NOTTP, NULL, outer_trans, NULL, "BATCH", 0, NULL);
    assert(status == YDB_OK);
}

