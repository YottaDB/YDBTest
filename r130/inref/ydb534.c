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

#include "gtm_stdlib.h"
#include "libyottadb.h"

int do_abort(uint64_t tptoken, ydb_buffer_t *errstr, void *ignored) {
    abort();
}

int main() {
    ydb_tp_st(YDB_NOTTP, NULL, do_abort, NULL, "BATCH", 0, NULL);
}

